import { logger } from '../config/logger.js';

/**
 * Maintenance middleware for subscription routes
 * Returns 503 Service Unavailable when maintenance mode is enabled
 */
export const subscriptionMaintenanceMiddleware = (req, res, next) => {
    const maintenanceMode = process.env.SUBSCRIPTION_MAINTENANCE === 'true' || false;

    if (maintenanceMode) {
        logger.warn(`Subscription maintenance mode active - blocking request to ${req.path}`, {
            path: req.path,
            method: req.method,
            ip: req.ip,
            userAgent: req.headers['user-agent']
        });

        return res.status(503).json({
            success: false,
            message: 'Abonelik servisi geçici bakımda.',
            error: 'SERVICE_MAINTENANCE',
            details: {
                service: 'subscription',
                status: 'maintenance',
                estimatedReturnTime: '1-2 saat',
            },
            retryAfter: 3600 // 1 hour in seconds
        });
    }

    next();
};

/**
 * Generic maintenance middleware for any feature
 */
export const createMaintenanceMiddleware = (featureName, envVar) => {
    return (req, res, next) => {
        const maintenanceMode = process.env[envVar] === 'true' || false;

        if (maintenanceMode) {
            logger.warn(`${featureName} maintenance mode active - blocking request to ${req.path}`, {
                feature: featureName,
                path: req.path,
                method: req.method,
                ip: req.ip
            });

            return res.status(503).json({
                success: false,
                message: `${featureName} servisi geçici bakımda.`,
                error: 'SERVICE_MAINTENANCE',
                details: {
                    service: featureName.toLowerCase(),
                    status: 'maintenance',
                },
                retryAfter: 3600
            });
        }

        next();
    };
}; 