import rateLimit from 'express-rate-limit';
import { isDevelopment } from '@src/config/env';

// General rate limiting
export const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: isDevelopment ? 1000 : 100, // limit each IP to 100 requests per windowMs in production
    message: {
        success: false,
        error: {
            message: 'Too many requests from this IP, please try again later.',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Strict rate limiting for auth endpoints
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: isDevelopment ? 100 : 5, // limit each IP to 5 auth requests per windowMs in production
    message: {
        success: false,
        error: {
            message: 'Too many authentication attempts, please try again later.',
        },
    },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true, // Don't count successful requests
});
