import { PrismaClient } from '@prisma/client';
import { isDevelopment } from '@src/config/env';

const globalForPrisma = globalThis as unknown as {
    prisma: PrismaClient | undefined;
};

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
    log: isDevelopment ? ['query', 'error', 'warn'] : ['error'],
});

if (isDevelopment) globalForPrisma.prisma = prisma;

// Graceful shutdown
process.on('beforeExit', async () => {
    await prisma.$disconnect();
});
