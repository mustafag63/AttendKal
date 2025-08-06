import { PrismaClient } from '@prisma/client';
import { logger } from '../config/logger.js';
import { isDevelopment } from '../config/index.js';

// Prisma singleton instance
class PrismaManager {
    constructor() {
        this.client = null;
    }

    getClient() {
        if (!this.client) {
            this.client = new PrismaClient({
                log: isDevelopment()
                    ? ['query', 'info', 'warn', 'error']
                    : ['warn', 'error'],
                errorFormat: 'pretty',
            });

            // Connection lifecycle events
            this.client.$on('beforeExit', async () => {
                logger.info('Prisma client disconnecting...');
            });

            // Global error handling for database operations
            this.client.$use(async (params, next) => {
                const before = Date.now();

                try {
                    const result = await next(params);
                    const after = Date.now();

                    if (isDevelopment()) {
                        logger.debug(`Query ${params.model}.${params.action} took ${after - before}ms`);
                    }

                    return result;
                } catch (error) {
                    logger.error(`Database error in ${params.model}.${params.action}:`, error);
                    throw error;
                }
            });
        }

        return this.client;
    }

    async disconnect() {
        if (this.client) {
            await this.client.$disconnect();
            this.client = null;
            logger.info('Prisma client disconnected');
        }
    }

    async healthCheck() {
        try {
            await this.getClient().$queryRaw`SELECT 1`;
            return { status: 'healthy', timestamp: new Date().toISOString() };
        } catch (error) {
            logger.error('Database health check failed:', error);
            return {
                status: 'unhealthy',
                error: error.message,
                timestamp: new Date().toISOString()
            };
        }
    }
}

// Export singleton instance
const prismaManager = new PrismaManager();
export const prisma = prismaManager.getClient();
export default prismaManager;

// Graceful shutdown handling
process.on('SIGINT', async () => {
    logger.info('SIGINT received, disconnecting Prisma client...');
    await prismaManager.disconnect();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    logger.info('SIGTERM received, disconnecting Prisma client...');
    await prismaManager.disconnect();
    process.exit(0);
});

// Handle uncaught exceptions
process.on('uncaughtException', async (error) => {
    logger.error('Uncaught exception:', error);
    await prismaManager.disconnect();
    process.exit(1);
});

process.on('unhandledRejection', async (reason, promise) => {
    logger.error('Unhandled rejection at:', promise, 'reason:', reason);
    await prismaManager.disconnect();
    process.exit(1);
}); 