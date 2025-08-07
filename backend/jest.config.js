export default {
    preset: 'node',
    extensionsToTreatAsEsm: ['.js'],
    globals: {
        'ts-jest': {
            useESM: true
        }
    },
    moduleNameMapping: {
        '^(\\.{1,2}/.*)\\.js$': '$1'
    },
    transform: {},
    testEnvironment: 'node',
    setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
    collectCoverageFrom: [
        'src/**/*.js',
        '!src/**/*.test.js',
        '!src/**/*.spec.js',
        '!src/server.js',
    ],
    coverageDirectory: 'coverage',
    coverageReporters: [
        'text',
        'lcov',
        'html',
        'json-summary'
    ],
    coverageThreshold: {
        global: {
            branches: 70,
            functions: 70,
            lines: 70,
            statements: 70,
        },
    },
    testMatch: [
        '<rootDir>/tests/**/*.test.js',
        '<rootDir>/tests/**/*.spec.js'
    ],
    verbose: true,
    collectCoverage: false,
    maxWorkers: 1,
    forceExit: true,
    detectOpenHandles: true
}; 