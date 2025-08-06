import { logger } from '../config/logger.js';

export const requestLogger = (req, res, next) => {
    const start = Date.now();

    // Skip logging for health check and static files
    const skipPaths = ['/health', '/favicon.ico'];
    if (skipPaths.includes(req.path)) {
        return next();
    }

    // Log request start
    logger.http(`➡️  ${req.method} ${req.originalUrl} - ${req.ip}`);

    // Capture response
    res.on('finish', () => {
        const duration = Date.now() - start;
        const statusCode = res.statusCode;
        const statusEmoji = statusCode >= 400 ? '❌' : statusCode >= 300 ? '⚠️' : '✅';

        logger.http(
            `⬅️  ${statusEmoji} ${req.method} ${req.originalUrl} - ${statusCode} - ${duration}ms - ${req.ip}`
        );
    });

    next();
}; 