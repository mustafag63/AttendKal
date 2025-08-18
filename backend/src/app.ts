import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { config, isDevelopment } from '@src/config/env';
import { errorHandler } from '@src/middlewares/error';
import { generalLimiter } from '@src/middlewares/rateLimiter';
import { authRoutes } from '@src/modules/auth';
import { courseRoutes } from '@src/modules/courses';
import { sessionRoutes } from '@src/modules/sessions';
import { attendanceRoutes } from '@src/modules/attendance';
import { reminderRoutes } from '@src/modules/reminders';
import { userRoutes } from '@src/modules/users';

const app = express();

// Security middlewares
app.use(helmet());
app.use(cors({
    origin: isDevelopment ? '*' : process.env.FRONTEND_URL,
    credentials: true,
}));

// Rate limiting
app.use(generalLimiter);

// Logging
if (isDevelopment) {
    app.use(morgan('dev'));
} else {
    app.use(morgan('combined'));
}

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        environment: config.nodeEnv,
        version: config.version,
    });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/reminders', reminderRoutes);
app.use('/api/users', userRoutes);

app.get('/api', (req, res) => {
    res.json({
        message: 'Attendkal API is running',
        version: config.version,
        timestamp: new Date().toISOString(),
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        error: {
            message: `Route ${req.method} ${req.originalUrl} not found`,
        },
    });
});

// Error handling middleware (must be last)
app.use(errorHandler);

export default app;
