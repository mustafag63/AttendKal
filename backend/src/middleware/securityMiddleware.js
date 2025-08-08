import rateLimit from 'express-rate-limit';
import { AppError } from './errorHandler.js';
import { config, isDevelopment } from '../config/index.js';
import { logger } from '../config/logger.js';

// Enhanced rate limiting for different endpoints
export const createRateLimit = (windowMs, max, message) => {
    return rateLimit({
        windowMs,
        max,
        message: {
            status: 'error',
            message,
            retryAfter: Math.ceil(windowMs / 1000),
        },
        standardHeaders: true,
        legacyHeaders: false,
        handler: (req, res, next) => {
            logger.warn(`Rate limit exceeded for IP: ${req.ip}, endpoint: ${req.originalUrl}`);
            res.status(429).json({
                status: 'error',
                message,
                retryAfter: Math.ceil(windowMs / 1000),
            });
        },
    });
};

// Strict rate limiting for auth endpoints
export const authRateLimit = createRateLimit(
    15 * 60 * 1000, // 15 minutes
    5, // limit each IP to 5 requests per windowMs
    'Too many authentication attempts from this IP, please try again after 15 minutes.'
);

// Standard rate limiting for API endpoints
export const apiRateLimit = createRateLimit(
    15 * 60 * 1000, // 15 minutes
    100, // limit each IP to 100 requests per windowMs
    'Too many requests from this IP, please try again later.'
);

// Strict rate limiting for password reset
export const passwordResetRateLimit = createRateLimit(
    60 * 60 * 1000, // 1 hour
    3, // limit each IP to 3 password reset requests per hour
    'Too many password reset attempts from this IP, please try again after 1 hour.'
);

// IP whitelist middleware for admin endpoints
export const ipWhitelist = (allowedIPs = []) => {
    return (req, res, next) => {
        if (!isDevelopment() && allowedIPs.length > 0) {
            const clientIP = req.ip || req.connection.remoteAddress;

            if (!allowedIPs.includes(clientIP)) {
                logger.warn(`Unauthorized IP access attempt: ${clientIP} to ${req.originalUrl}`);
                return next(new AppError('Access denied from this IP address', 403));
            }
        }
        next();
    };
};

// Request size limiter
export const requestSizeLimiter = (maxSize = '10mb') => {
    return (req, res, next) => {
        if (req.headers['content-length']) {
            const contentLength = parseInt(req.headers['content-length']);
            const maxSizeBytes = parseSize(maxSize);

            if (contentLength > maxSizeBytes) {
                return next(new AppError('Request entity too large', 413));
            }
        }
        next();
    };
};

// Helper function to parse size strings
const parseSize = (size) => {
    const units = { b: 1, kb: 1024, mb: 1024 * 1024, gb: 1024 * 1024 * 1024 };
    const match = size.toString().match(/^(\d+(?:\.\d+)?)\s*(b|kb|mb|gb)?$/i);

    if (!match) return 0;

    const value = parseFloat(match[1]);
    const unit = (match[2] || 'b').toLowerCase();

    return Math.floor(value * units[unit]);
};

// Security headers middleware
export const securityHeaders = (req, res, next) => {
    // Remove powered by header
    res.removeHeader('X-Powered-By');

    // Set security headers
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');

    if (!isDevelopment()) {
        res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
    }

    next();
};

// CORS preflight handler
export const handlePreflight = (req, res, next) => {
    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,PATCH,OPTIONS');
        res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        res.header('Access-Control-Max-Age', '86400'); // 24 hours
        return res.sendStatus(200);
    }
    next();
};

// Request timeout middleware
export const requestTimeout = (timeout = 30000) => {
    return (req, res, next) => {
        res.setTimeout(timeout, () => {
            logger.warn(`Request timeout for ${req.originalUrl} from IP: ${req.ip}`);
            if (!res.headersSent) {
                res.status(408).json({
                    status: 'error',
                    message: 'Request timeout',
                });
            }
        });
        next();
    };
}; 