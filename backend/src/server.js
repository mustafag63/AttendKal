import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import morgan from 'morgan';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger.js';

// Import utilities
import { logger } from './config/logger.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { requestLogger } from './middleware/requestLogger.js';
import { metricsMiddleware, metricsEndpoint } from './middleware/metricsMiddleware.js';

// Import routes
import authRoutes from './routes/authRoutes.js';
import courseRoutes from './routes/courseRoutes.js';
import attendanceRoutes from './routes/attendanceRoutes.js';
import subscriptionRoutes from './routes/subscriptionRoutes.js';
import userRoutes from './routes/userRoutes.js';
import healthRoutes from './routes/healthRoutes.js';

// Load environment variables
dotenv.config();

const app = express();
const DEFAULT_PORT = process.env.PORT || 3000;
const MAX_PORT = DEFAULT_PORT + 10; // Try up to 10 ports

// Trust proxy for rate limiting
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
    crossOriginEmbedderPolicy: false,
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", "data:", "https:"],
        },
    },
}));

// CORS configuration
const corsOptions = {
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : ['http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    credentials: true,
    maxAge: 86400, // 24 hours
};
app.use(cors(corsOptions));

// Compression middleware
app.use(compression());

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    message: {
        error: 'Too many requests from this IP, please try again later.',
        retryAfter: Math.ceil((parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000) / 1000),
    },
    standardHeaders: true,
    legacyHeaders: false,
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
} else {
    app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
}

app.use(requestLogger);

// Metrics collection middleware
app.use(metricsMiddleware);

// Metrics endpoint for Prometheus
app.get('/metrics', metricsEndpoint);

// Swagger documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
    explorer: true,
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'AttendKal API Documentation',
}));

// Health routes (before API routes for direct access)
app.use('/', healthRoutes);

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/users', userRoutes);

// Admin routes
import queueRoutes from './routes/queueRoutes.js';
app.use('/api/admin/queues', queueRoutes);

// API documentation endpoint
app.get('/api', (req, res) => {
    res.json({
        message: 'AttendKal API Server',
        version: '1.0.0',
        documentation: '/api-docs',
        health: '/health',
        port: req.get('host')?.split(':')[1] || DEFAULT_PORT,
        endpoints: {
            auth: '/api/auth',
            courses: '/api/courses',
            attendance: '/api/attendance',
            subscriptions: '/api/subscriptions',
            users: '/api/users',
        },
    });
});

// Error handling middleware (must be last)
app.use(notFoundHandler);
app.use(errorHandler);

let server;

// Function to find available port
const findAvailablePort = (startPort) => {
    return new Promise((resolve, reject) => {
        const testPort = (port) => {
            if (port > MAX_PORT) {
                reject(new Error(`No available port found between ${DEFAULT_PORT} and ${MAX_PORT}`));
                return;
            }

            const testServer = app.listen(port)
                .on('listening', () => {
                    testServer.close();
                    resolve(port);
                })
                .on('error', (err) => {
                    if (err.code === 'EADDRINUSE') {
                        logger.warn(`Port ${port} is busy, trying port ${port + 1}...`);
                        testPort(port + 1);
                    } else {
                        reject(err);
                    }
                });
        };

        testPort(startPort);
    });
};

// Graceful shutdown
const gracefulShutdown = (signal) => {
    logger.info(`${signal} signal received. Closing HTTP server...`);
    if (server) {
        server.close(() => {
            logger.info('HTTP server closed.');
            process.exit(0);
        });
    } else {
        process.exit(0);
    }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server
const startServer = async () => {
    try {
        const availablePort = await findAvailablePort(DEFAULT_PORT);

        server = app.listen(availablePort, () => {
            logger.info(`🚀 AttendKal API Server running on port ${availablePort}`);
            logger.info(`📚 Environment: ${process.env.NODE_ENV || 'development'}`);
            logger.info(`🔗 API URL: http://localhost:${availablePort}/api`);
            logger.info(`❤️  Health Check: http://localhost:${availablePort}/health`);
            logger.info(`📖 API Docs: http://localhost:${availablePort}/api-docs`);
        });

        server.on('error', (err) => {
            logger.error('Server error:', err);
            process.exit(1);
        });

    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
};

// Start the server
startServer();

export default app; 