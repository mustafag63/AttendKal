import { logger } from '../config/logger.js';

// Maintenance mode middleware
export const maintenanceMode = (req, res, next) => {
  const isMaintenanceMode = process.env.MAINTENANCE_MODE === 'true';
  const maintenanceMessage = process.env.MAINTENANCE_MESSAGE || 'System is under maintenance. Please try again later.';

  // Allow health checks during maintenance
  if (req.path === '/health' || req.path.startsWith('/api-docs')) {
    return next();
  }

  // Allow admin access during maintenance
  if (req.user && req.user.role === 'ADMIN') {
    return next();
  }

  if (isMaintenanceMode) {
    logger.info('Maintenance mode request blocked', {
      ip: req.ip,
      path: req.path,
      method: req.method,
      userAgent: req.get('User-Agent'),
    });

    return res.status(503).json({
      status: 'maintenance',
      message: maintenanceMessage,
      retryAfter: 3600, // 1 hour
      timestamp: new Date().toISOString(),
    });
  }

  next();
};

// Feature-specific maintenance middleware
export const featureMaintenanceMode = (feature) => {
  return (req, res, next) => {
    const maintenanceKey = `${feature.toUpperCase()}_MAINTENANCE`;
    const isFeatureDown = process.env[maintenanceKey] === 'true';

    if (isFeatureDown) {
      const message = process.env[`${maintenanceKey}_MESSAGE`] ||
        `${feature} service is temporarily unavailable.`;

      logger.info(`${feature} maintenance mode`, {
        ip: req.ip,
        path: req.path,
        method: req.method,
        feature: feature,
      });

      return res.status(503).json({
        status: 'service_unavailable',
        message: message,
        feature: feature,
        retryAfter: 3600,
        timestamp: new Date().toISOString(),
      });
    }

    next();
  };
};

// Check service health for maintenance decisions
export const healthCheck = (req, res, next) => {
  const checks = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  };

  // Add maintenance status
  checks.maintenance = {
    enabled: process.env.MAINTENANCE_MODE === 'true',
    features: {
      subscription: process.env.SUBSCRIPTION_MAINTENANCE === 'true',
      notifications: process.env.NOTIFICATIONS_MAINTENANCE === 'true',
      analytics: process.env.ANALYTICS_MAINTENANCE === 'true',
    },
  };

  res.status(200).json(checks);
}; 