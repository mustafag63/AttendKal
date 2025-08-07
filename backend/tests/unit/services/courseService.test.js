import { jest } from '@jest/globals';
import { courseService } from '../../../src/services/courseService.js';
import { prisma } from '../../../src/utils/prisma.js';

// Mock Prisma
jest.mock('../../../src/utils/prisma.js', () => ({
    prisma: {
        course: {
            findMany: jest.fn(),
            findUnique: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
            count: jest.fn(),
        },
        courseSchedule: {
            createMany: jest.fn(),
            deleteMany: jest.fn(),
        },
        subscription: {
            findUnique: jest.fn(),
        },
    },
}));

describe('CourseService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('getCourses', () => {
        it('should return all courses for user', async () => {
            const mockCourses = [
                {
                    id: 'course_1',
                    name: 'Mathematics',
                    code: 'MATH101',
                    instructor: 'Dr. Smith',
                    isActive: true,
                    schedules: [],
                },
                {
                    id: 'course_2',
                    name: 'Physics',
                    code: 'PHYS101',
                    instructor: 'Dr. Johnson',
                    isActive: true,
                    schedules: [],
                },
            ];

            prisma.course.findMany.mockResolvedValue(mockCourses);

            const result = await courseService.getCourses('user_123');

            expect(result).toEqual(mockCourses);
            expect(prisma.course.findMany).toHaveBeenCalledWith({
                where: {
                    userId: 'user_123',
                    isActive: true,
                },
                include: {
                    schedules: true,
                },
                orderBy: {
                    createdAt: 'desc',
                },
            });
        });

        it('should return empty array when no courses found', async () => {
            prisma.course.findMany.mockResolvedValue([]);

            const result = await courseService.getCourses('user_123');

            expect(result).toEqual([]);
        });
    });

    describe('getCourseById', () => {
        it('should return course by id', async () => {
            const mockCourse = {
                id: 'course_1',
                name: 'Mathematics',
                code: 'MATH101',
                userId: 'user_123',
                schedules: [],
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);

            const result = await courseService.getCourseById('course_1', 'user_123');

            expect(result).toEqual(mockCourse);
            expect(prisma.course.findUnique).toHaveBeenCalledWith({
                where: {
                    id: 'course_1',
                    userId: 'user_123',
                    isActive: true,
                },
                include: {
                    schedules: true,
                },
            });
        });

        it('should return null when course not found', async () => {
            prisma.course.findUnique.mockResolvedValue(null);

            const result = await courseService.getCourseById('course_1', 'user_123');

            expect(result).toBeNull();
        });
    });

    describe('createCourse', () => {
        it('should create course successfully for PRO user', async () => {
            const courseData = {
                name: 'Mathematics',
                code: 'MATH101',
                instructor: 'Dr. Smith',
                color: '#2196F3',
                schedules: [
                    { dayOfWeek: 1, startTime: '09:00', endTime: '10:30' },
                ],
            };

            const mockProSubscription = { type: 'PRO', isActive: true };
            const mockCreatedCourse = {
                id: 'course_1',
                userId: 'user_123',
                ...courseData,
                schedules: courseData.schedules,
            };

            prisma.subscription.findUnique.mockResolvedValue(mockProSubscription);
            prisma.course.count.mockResolvedValue(5); // Any number for PRO users
            prisma.course.create.mockResolvedValue(mockCreatedCourse);

            const result = await courseService.createCourse('user_123', courseData);

            expect(result).toEqual(mockCreatedCourse);
            expect(prisma.course.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    userId: 'user_123',
                    name: 'Mathematics',
                    code: 'MATH101',
                    instructor: 'Dr. Smith',
                }),
            });
        });

        it('should create course for FREE user within limit', async () => {
            const courseData = {
                name: 'Mathematics',
                code: 'MATH101',
                instructor: 'Dr. Smith',
            };

            const mockFreeSubscription = { type: 'FREE', isActive: true };
            const mockCreatedCourse = { id: 'course_1', ...courseData };

            prisma.subscription.findUnique.mockResolvedValue(mockFreeSubscription);
            prisma.course.count.mockResolvedValue(1); // Under limit
            prisma.course.create.mockResolvedValue(mockCreatedCourse);

            const result = await courseService.createCourse('user_123', courseData);

            expect(result).toEqual(mockCreatedCourse);
        });

        it('should throw error when FREE user exceeds course limit', async () => {
            const courseData = {
                name: 'Mathematics',
                code: 'MATH101',
                instructor: 'Dr. Smith',
            };

            const mockFreeSubscription = { type: 'FREE', isActive: true };

            prisma.subscription.findUnique.mockResolvedValue(mockFreeSubscription);
            prisma.course.count.mockResolvedValue(2); // At limit

            await expect(courseService.createCourse('user_123', courseData))
                .rejects.toThrow('Course limit exceeded. Upgrade to Pro for unlimited courses.');
        });

        it('should handle duplicate course code error', async () => {
            const courseData = {
                name: 'Mathematics',
                code: 'MATH101',
                instructor: 'Dr. Smith',
            };

            const mockProSubscription = { type: 'PRO', isActive: true };
            const duplicateError = new Error('Unique constraint violation');
            duplicateError.code = 'P2002';

            prisma.subscription.findUnique.mockResolvedValue(mockProSubscription);
            prisma.course.count.mockResolvedValue(1);
            prisma.course.create.mockRejectedValue(duplicateError);

            await expect(courseService.createCourse('user_123', courseData))
                .rejects.toThrow('Course with this code already exists');
        });
    });

    describe('updateCourse', () => {
        it('should update course successfully', async () => {
            const updateData = {
                name: 'Advanced Mathematics',
                instructor: 'Dr. Smith Jr.',
                schedules: [
                    { dayOfWeek: 2, startTime: '10:00', endTime: '11:30' },
                ],
            };

            const mockExistingCourse = {
                id: 'course_1',
                userId: 'user_123',
                name: 'Mathematics',
            };

            const mockUpdatedCourse = {
                ...mockExistingCourse,
                ...updateData,
            };

            prisma.course.findUnique.mockResolvedValue(mockExistingCourse);
            prisma.courseSchedule.deleteMany.mockResolvedValue({ count: 1 });
            prisma.course.update.mockResolvedValue(mockUpdatedCourse);

            const result = await courseService.updateCourse('course_1', 'user_123', updateData);

            expect(result).toEqual(mockUpdatedCourse);
            expect(prisma.course.update).toHaveBeenCalledWith({
                where: { id: 'course_1' },
                data: expect.objectContaining({
                    name: 'Advanced Mathematics',
                    instructor: 'Dr. Smith Jr.',
                }),
                include: { schedules: true },
            });
        });

        it('should throw error when course not found', async () => {
            prisma.course.findUnique.mockResolvedValue(null);

            await expect(courseService.updateCourse('course_1', 'user_123', {}))
                .rejects.toThrow('Course not found');
        });
    });

    describe('deleteCourse', () => {
        it('should soft delete course successfully', async () => {
            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                isActive: true,
            };

            const mockDeletedCourse = {
                ...mockCourse,
                isActive: false,
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);
            prisma.course.update.mockResolvedValue(mockDeletedCourse);

            const result = await courseService.deleteCourse('course_1', 'user_123');

            expect(result).toEqual(mockDeletedCourse);
            expect(prisma.course.update).toHaveBeenCalledWith({
                where: { id: 'course_1' },
                data: { isActive: false },
            });
        });

        it('should throw error when course not found', async () => {
            prisma.course.findUnique.mockResolvedValue(null);

            await expect(courseService.deleteCourse('course_1', 'user_123'))
                .rejects.toThrow('Course not found');
        });
    });

    describe('validateCourseAccess', () => {
        it('should return true for valid course access', async () => {
            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                isActive: true,
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);

            const result = await courseService.validateCourseAccess('course_1', 'user_123');

            expect(result).toBe(true);
        });

        it('should return false for invalid course access', async () => {
            prisma.course.findUnique.mockResolvedValue(null);

            const result = await courseService.validateCourseAccess('course_1', 'user_123');

            expect(result).toBe(false);
        });
    });
}); 