import { PrismaClient, Prisma } from '@prisma/client';
import { isDevelopment } from '@src/config/env';

const globalForPrisma = globalThis as unknown as {
    prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
    log: isDevelopment
        ? ['query', 'error', 'warn', 'info']
        : ['error', 'warn'],
    errorFormat: 'pretty',
    datasources: {
        db: {
            url: process.env.DATABASE_URL,
        },
    },
});

// Database connection health check
export async function checkDatabaseConnection(): Promise<boolean> {
    try {
        await prisma.$queryRaw`SELECT 1`;
        return true;
    } catch (error) {
        console.error('Database connection failed:', error);
        return false;
    }
}

// Graceful database disconnection
export async function disconnectDatabase(): Promise<void> {
    try {
        await prisma.$disconnect();
        console.log('Database disconnected successfully');
    } catch (error) {
        console.error('Error disconnecting from database:', error);
    }
}

// Helper function to execute database operations with retries
export async function withRetry<T>(
    operation: () => Promise<T>,
    maxRetries: number = 3,
    delay: number = 1000
): Promise<T> {
    let lastError: Error;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return await operation();
        } catch (error) {
            lastError = error as Error;
            console.warn(`Database operation failed (attempt ${attempt}/${maxRetries}):`, error);

            if (attempt === maxRetries) {
                break;
            }

            // Wait before retrying
            await new Promise(resolve => setTimeout(resolve, delay * attempt));
        }
    }

    throw lastError!;
}

// Ensure single instance in development
if (isDevelopment) {
    globalForPrisma.prisma = prisma;
}

// Graceful shutdown handlers
const gracefulShutdown = async (signal: string) => {
    console.log(`Received ${signal}, closing database connection...`);
    await disconnectDatabase();
    process.exit(0);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('beforeExit', disconnectDatabase);

// Database middleware for logging and performance monitoring
if (isDevelopment) {
    prisma.$use(async (params: any, next: any) => {
        const start = Date.now();
        const result = await next(params);
        const duration = Date.now() - start;

        if (duration > 1000) {
            console.warn(`Slow query detected: ${params.model}.${params.action} took ${duration}ms`);
        }

        return result;
    });
}
