import express from 'express';
import { prisma } from '../utils/prisma.js';
import { logger } from '../config/logger.js';
import { config } from '../config/index.js';

const router = express.Router();

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Basic health check
 *     description: Returns basic server health status
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Server is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: OK
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 environment:
 *                   type: string
 *                   example: development
 *                 version:
 *                   type: string
 *                   example: 1.0.0
 *                 uptime:
 *                   type: number
 *                   example: 3600.123
 */
router.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: config.server.nodeEnv,
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime(),
  });
});

/**
 * @swagger
 * /health/detailed:
 *   get:
 *     summary: Detailed health check
 *     description: Returns detailed health status including database connectivity
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Detailed health information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: OK
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 services:
 *                   type: object
 *                   properties:
 *                     database:
 *                       type: object
 *                       properties:
 *                         status:
 *                           type: string
 *                           example: healthy
 *                         responseTime:
 *                           type: number
 *                           example: 25
 *                     memory:
 *                       type: object
 *                       properties:
 *                         usage:
 *                           type: object
 *                         percent:
 *                           type: number
 *                     system:
 *                       type: object
 *                       properties:
 *                         platform:
 *                           type: string
 *                         arch:
 *                           type: string
 *                         nodeVersion:
 *                           type: string
 *       503:
 *         description: Service unavailable
 */
router.get('/health/detailed', async (req, res) => {
  const startTime = Date.now();
  const healthStatus = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: config.server.nodeEnv,
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime(),
    services: {},
  };

  try {
    // Database health check
    const dbStart = Date.now();
    await prisma.$queryRaw`SELECT 1`;
    const dbResponseTime = Date.now() - dbStart;

    healthStatus.services.database = {
      status: 'healthy',
      responseTime: dbResponseTime,
    };

    // Memory usage
    const memUsage = process.memoryUsage();
    healthStatus.services.memory = {
      usage: {
        rss: Math.round(memUsage.rss / 1024 / 1024), // MB
        heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024), // MB
        heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024), // MB
        external: Math.round(memUsage.external / 1024 / 1024), // MB
      },
      percent: Math.round((memUsage.heapUsed / memUsage.heapTotal) * 100),
    };

    // System information
    healthStatus.services.system = {
      platform: process.platform,
      arch: process.arch,
      nodeVersion: process.version,
      pid: process.pid,
    };

    // CPU usage (basic)
    const cpuUsage = process.cpuUsage();
    healthStatus.services.cpu = {
      user: cpuUsage.user,
      system: cpuUsage.system,
    };

    const responseTime = Date.now() - startTime;
    healthStatus.responseTime = responseTime;

    // Determine overall status
    if (dbResponseTime > 1000) {
      healthStatus.status = 'DEGRADED';
    }

    if (healthStatus.services.memory.percent > 90) {
      healthStatus.status = 'DEGRADED';
    }

    res.status(healthStatus.status === 'OK' ? 200 : 503).json(healthStatus);
  } catch (error) {
    logger.error('Health check failed:', error);

    healthStatus.status = 'UNHEALTHY';
    healthStatus.services.database = {
      status: 'unhealthy',
      error: error.message,
    };

    res.status(503).json(healthStatus);
  }
});

/**
 * @swagger
 * /health/liveness:
 *   get:
 *     summary: Liveness probe
 *     description: Simple liveness check for Kubernetes/Docker
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Service is alive
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 alive:
 *                   type: boolean
 *                   example: true
 */
router.get('/health/liveness', (req, res) => {
  res.status(200).json({ alive: true });
});

/**
 * @swagger
 * /health/readiness:
 *   get:
 *     summary: Readiness probe
 *     description: Check if service is ready to accept traffic
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Service is ready
 *       503:
 *         description: Service is not ready
 */
router.get('/health/readiness', async (req, res) => {
  try {
    // Check database connectivity
    await prisma.$queryRaw`SELECT 1`;

    // Check memory usage
    const memUsage = process.memoryUsage();
    const memPercent = (memUsage.heapUsed / memUsage.heapTotal) * 100;

    if (memPercent > 95) {
      throw new Error('Memory usage too high');
    }

    res.status(200).json({
      ready: true,
      checks: {
        database: 'OK',
        memory: 'OK',
      },
    });
  } catch (error) {
    logger.warn('Readiness check failed:', error.message);
    res.status(503).json({
      ready: false,
      error: error.message,
    });
  }
});

/**
 * @swagger
 * /health/metrics:
 *   get:
 *     summary: Basic metrics
 *     description: Returns basic application metrics
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Application metrics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 metrics:
 *                   type: object
 */
router.get('/health/metrics', async (req, res) => {
  try {
    const metrics = {
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      eventLoop: {
        delay: await getEventLoopDelay(),
      },
    };

    // Database metrics
    try {
      const userCount = await prisma.user.count();
      const courseCount = await prisma.course.count({ where: { isActive: true } });
      const attendanceCount = await prisma.attendance.count();

      metrics.database = {
        users: userCount,
        activeCourses: courseCount,
        attendanceRecords: attendanceCount,
      };
    } catch (error) {
      metrics.database = { error: 'Unable to fetch database metrics' };
    }

    res.status(200).json(metrics);
  } catch (error) {
    logger.error('Metrics collection failed:', error);
    res.status(500).json({
      error: 'Failed to collect metrics',
      message: error.message,
    });
  }
});

// Helper function to measure event loop delay
function getEventLoopDelay() {
  return new Promise((resolve) => {
    const start = process.hrtime.bigint();
    setImmediate(() => {
      const delta = process.hrtime.bigint() - start;
      resolve(Number(delta) / 1000000); // Convert to milliseconds
    });
  });
}

export default router; 