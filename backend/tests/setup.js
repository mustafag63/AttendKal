// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key';
process.env.JWT_REFRESH_SECRET = 'test-jwt-refresh-secret-key';
process.env.JWT_EXPIRE = '15m';
process.env.JWT_REFRESH_EXPIRE = '7d';
process.env.BCRYPT_ROUNDS = '4'; // Lower rounds for faster tests
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/attendkal_test';

import { jest } from '@jest/globals';

// Global test timeout
jest.setTimeout(30000);

// Mock console methods in tests
global.console = {
    ...console,
    // Uncomment below lines to suppress console output in tests
    // log: jest.fn(),
    // debug: jest.fn(),
    // info: jest.fn(),
    // warn: jest.fn(),
    // error: jest.fn(),
};

// Global test helpers
global.testHelpers = {
    // Create test user data
    createTestUser: (overrides = {}) => ({
        name: 'Test User',
        email: 'test@example.com',
        password: 'TestPass123',
        ...overrides,
    }),

    // Create test course data
    createTestCourse: (overrides = {}) => ({
        name: 'Test Course',
        code: 'TC101',
        description: 'Test course description',
        instructor: 'Test Instructor',
        color: '#2196F3',
        schedule: [
            {
                dayOfWeek: 1, // Monday
                startTime: '09:00',
                endTime: '10:30',
                room: 'Room 101',
            },
        ],
        ...overrides,
    }),

    // Create test attendance data
    createTestAttendance: (overrides = {}) => ({
        date: new Date(),
        status: 'PRESENT',
        note: 'Test note',
        ...overrides,
    }),

    // Sleep utility for async tests
    sleep: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
};

// Setup and teardown hooks
beforeAll(async () => {
    // Global setup before all tests
});

afterAll(async () => {
    // Global cleanup after all tests
});

beforeEach(async () => {
    // Setup before each test
});

afterEach(async () => {
    // Cleanup after each test
}); 