import { PrismaClient } from '@prisma/client';

// Global test setup
let prisma: PrismaClient;

declare const beforeAll: (fn: () => Promise<void>) => void;
declare const afterAll: (fn: () => Promise<void>) => void;
declare const beforeEach: (fn: () => Promise<void>) => void;

beforeAll(async () => {
    // Setup test database connection
    prisma = new PrismaClient({
        datasources: {
            db: {
                url: process.env.DATABASE_URL || 'postgresql://test:test@localhost:5432/attendkal_test'
            }
        }
    });

    // Connect to database
    await prisma.$connect();
});

afterAll(async () => {
    // Cleanup
    await prisma.$disconnect();
});

beforeEach(async () => {
    // Clean database before each test
    await prisma.attendance.deleteMany();
    await prisma.session.deleteMany();
    await prisma.meeting.deleteMany();
    await prisma.course.deleteMany();
    await prisma.user.deleteMany();
});

// Export for use in tests
export { prisma };
