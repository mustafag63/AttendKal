import swaggerJsdoc from 'swagger-jsdoc';
import { config } from './index.js';

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'AttendKal API',
            version: '1.0.0',
            description: 'Smart student attendance tracking system API',
            termsOfService: 'https://attendkal.com/terms',
            contact: {
                name: 'AttendKal Support',
                url: 'https://attendkal.com/support',
                email: 'support@attendkal.com',
            },
            license: {
                name: 'MIT',
                url: 'https://opensource.org/licenses/MIT',
            },
        },
        servers: [
            {
                url: `http://localhost:${config.server.port}/api`,
                description: 'Development server',
            },
            {
                url: 'https://api.attendkal.com/api',
                description: 'Production server',
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                    description: 'Enter JWT token',
                },
            },
            schemas: {
                // Error response schema
                Error: {
                    type: 'object',
                    properties: {
                        status: {
                            type: 'string',
                            example: 'error',
                        },
                        message: {
                            type: 'string',
                            example: 'Something went wrong',
                        },
                    },
                },

                // Success response schema
                Success: {
                    type: 'object',
                    properties: {
                        status: {
                            type: 'string',
                            example: 'success',
                        },
                        data: {
                            type: 'object',
                        },
                    },
                },

                // Pagination schema
                Pagination: {
                    type: 'object',
                    properties: {
                        page: {
                            type: 'integer',
                            example: 1,
                        },
                        limit: {
                            type: 'integer',
                            example: 10,
                        },
                        total: {
                            type: 'integer',
                            example: 100,
                        },
                        totalPages: {
                            type: 'integer',
                            example: 10,
                        },
                        hasNext: {
                            type: 'boolean',
                            example: true,
                        },
                        hasPrev: {
                            type: 'boolean',
                            example: false,
                        },
                    },
                },

                // User schemas
                User: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'cuid',
                            example: 'ckvzq1x2z0000qh8z1j9v2g9u',
                        },
                        email: {
                            type: 'string',
                            format: 'email',
                            example: 'john@example.com',
                        },
                        name: {
                            type: 'string',
                            example: 'John Doe',
                        },
                        avatar: {
                            type: 'string',
                            format: 'url',
                            nullable: true,
                            example: 'https://example.com/avatar.jpg',
                        },
                        role: {
                            type: 'string',
                            enum: ['STUDENT', 'TEACHER', 'ADMIN'],
                            example: 'STUDENT',
                        },
                        isActive: {
                            type: 'boolean',
                            example: true,
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time',
                            example: '2023-01-01T00:00:00.000Z',
                        },
                    },
                },

                // Course schemas
                CourseSchedule: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'cuid',
                        },
                        dayOfWeek: {
                            type: 'integer',
                            minimum: 0,
                            maximum: 6,
                            description: '0=Sunday, 1=Monday, ..., 6=Saturday',
                            example: 1,
                        },
                        startTime: {
                            type: 'string',
                            pattern: '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                            example: '09:00',
                        },
                        endTime: {
                            type: 'string',
                            pattern: '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                            example: '10:30',
                        },
                        room: {
                            type: 'string',
                            nullable: true,
                            example: 'Room 101',
                        },
                        dayName: {
                            type: 'string',
                            example: 'Monday',
                        },
                    },
                },

                Course: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'cuid',
                        },
                        name: {
                            type: 'string',
                            example: 'Mathematics 101',
                        },
                        code: {
                            type: 'string',
                            example: 'MATH101',
                        },
                        description: {
                            type: 'string',
                            nullable: true,
                            example: 'Introduction to Mathematics',
                        },
                        instructor: {
                            type: 'string',
                            example: 'Dr. Smith',
                        },
                        color: {
                            type: 'string',
                            pattern: '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
                            example: '#2196F3',
                        },
                        isActive: {
                            type: 'boolean',
                            example: true,
                        },
                        schedule: {
                            type: 'array',
                            items: {
                                $ref: '#/components/schemas/CourseSchedule',
                            },
                        },
                        totalAttendances: {
                            type: 'integer',
                            example: 10,
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                        updatedAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                    },
                },

                // Attendance schemas
                Attendance: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'cuid',
                        },
                        date: {
                            type: 'string',
                            format: 'date',
                            example: '2023-01-01',
                        },
                        status: {
                            type: 'string',
                            enum: ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'],
                            example: 'PRESENT',
                        },
                        note: {
                            type: 'string',
                            nullable: true,
                            example: 'On time',
                        },
                        course: {
                            type: 'object',
                            properties: {
                                id: { type: 'string' },
                                name: { type: 'string' },
                                code: { type: 'string' },
                                color: { type: 'string' },
                            },
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                        updatedAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                    },
                },

                // Subscription schemas
                Subscription: {
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string',
                            format: 'cuid',
                        },
                        type: {
                            type: 'string',
                            enum: ['FREE', 'PRO'],
                            example: 'FREE',
                        },
                        startDate: {
                            type: 'string',
                            format: 'date-time',
                        },
                        endDate: {
                            type: 'string',
                            format: 'date-time',
                            nullable: true,
                        },
                        isActive: {
                            type: 'boolean',
                            example: true,
                        },
                        createdAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                        updatedAt: {
                            type: 'string',
                            format: 'date-time',
                        },
                    },
                },

                // Request schemas
                RegisterRequest: {
                    type: 'object',
                    required: ['name', 'email', 'password', 'confirmPassword'],
                    properties: {
                        name: {
                            type: 'string',
                            minLength: 2,
                            maxLength: 50,
                            example: 'John Doe',
                        },
                        email: {
                            type: 'string',
                            format: 'email',
                            example: 'john@example.com',
                        },
                        password: {
                            type: 'string',
                            minLength: 6,
                            pattern: '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)',
                            example: 'MyPass123',
                        },
                        confirmPassword: {
                            type: 'string',
                            example: 'MyPass123',
                        },
                    },
                },

                LoginRequest: {
                    type: 'object',
                    required: ['email', 'password'],
                    properties: {
                        email: {
                            type: 'string',
                            format: 'email',
                            example: 'john@example.com',
                        },
                        password: {
                            type: 'string',
                            example: 'MyPass123',
                        },
                    },
                },

                CreateCourseRequest: {
                    type: 'object',
                    required: ['name', 'code', 'instructor'],
                    properties: {
                        name: {
                            type: 'string',
                            minLength: 2,
                            maxLength: 100,
                            example: 'Mathematics 101',
                        },
                        code: {
                            type: 'string',
                            minLength: 2,
                            maxLength: 20,
                            example: 'MATH101',
                        },
                        description: {
                            type: 'string',
                            maxLength: 500,
                            nullable: true,
                            example: 'Introduction to Mathematics',
                        },
                        instructor: {
                            type: 'string',
                            minLength: 2,
                            maxLength: 100,
                            example: 'Dr. Smith',
                        },
                        color: {
                            type: 'string',
                            pattern: '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
                            example: '#2196F3',
                        },
                        schedule: {
                            type: 'array',
                            items: {
                                type: 'object',
                                required: ['dayOfWeek', 'startTime', 'endTime'],
                                properties: {
                                    dayOfWeek: {
                                        type: 'integer',
                                        minimum: 0,
                                        maximum: 6,
                                        example: 1,
                                    },
                                    startTime: {
                                        type: 'string',
                                        pattern: '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                                        example: '09:00',
                                    },
                                    endTime: {
                                        type: 'string',
                                        pattern: '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                                        example: '10:30',
                                    },
                                    room: {
                                        type: 'string',
                                        maxLength: 50,
                                        nullable: true,
                                        example: 'Room 101',
                                    },
                                },
                            },
                        },
                    },
                },

                MarkAttendanceRequest: {
                    type: 'object',
                    required: ['courseId', 'date', 'status'],
                    properties: {
                        courseId: {
                            type: 'string',
                            format: 'cuid',
                            example: 'ckvzq1x2z0000qh8z1j9v2g9u',
                        },
                        date: {
                            type: 'string',
                            format: 'date',
                            example: '2023-01-01',
                        },
                        status: {
                            type: 'string',
                            enum: ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'],
                            example: 'PRESENT',
                        },
                        note: {
                            type: 'string',
                            maxLength: 255,
                            nullable: true,
                            example: 'On time',
                        },
                    },
                },
            },
        },
        security: [
            {
                bearerAuth: [],
            },
        ],
    },
    apis: [
        './src/routes/*.js',
        './src/controllers/*.js',
    ],
};

export const swaggerSpec = swaggerJsdoc(options);
export default swaggerSpec; 