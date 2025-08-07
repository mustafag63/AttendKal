import { jest } from '@jest/globals';
import { attendanceService } from '../../../src/services/attendanceService.js';
import { prisma } from '../../../src/utils/prisma.js';

// Mock Prisma
jest.mock('../../../src/utils/prisma.js', () => ({
    prisma: {
        attendance: {
            findMany: jest.fn(),
            findUnique: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            upsert: jest.fn(),
            groupBy: jest.fn(),
        },
        course: {
            findUnique: jest.fn(),
        },
    },
}));

describe('AttendanceService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('getAttendanceRecords', () => {
        it('should return attendance records for user', async () => {
            const mockAttendanceRecords = [
                {
                    id: 'att_1',
                    userId: 'user_123',
                    courseId: 'course_1',
                    date: new Date('2024-01-15'),
                    status: 'PRESENT',
                    course: { name: 'Mathematics', code: 'MATH101' },
                },
                {
                    id: 'att_2',
                    userId: 'user_123',
                    courseId: 'course_2',
                    date: new Date('2024-01-15'),
                    status: 'ABSENT',
                    course: { name: 'Physics', code: 'PHYS101' },
                },
            ];

            prisma.attendance.findMany.mockResolvedValue(mockAttendanceRecords);

            const result = await attendanceService.getAttendanceRecords('user_123');

            expect(result).toEqual(mockAttendanceRecords);
            expect(prisma.attendance.findMany).toHaveBeenCalledWith({
                where: { userId: 'user_123' },
                include: {
                    course: {
                        select: { name: true, code: true, color: true },
                    },
                },
                orderBy: { date: 'desc' },
            });
        });

        it('should filter by course when courseId provided', async () => {
            const mockAttendanceRecords = [
                {
                    id: 'att_1',
                    userId: 'user_123',
                    courseId: 'course_1',
                    status: 'PRESENT',
                },
            ];

            prisma.attendance.findMany.mockResolvedValue(mockAttendanceRecords);

            const result = await attendanceService.getAttendanceRecords('user_123', 'course_1');

            expect(result).toEqual(mockAttendanceRecords);
            expect(prisma.attendance.findMany).toHaveBeenCalledWith({
                where: {
                    userId: 'user_123',
                    courseId: 'course_1',
                },
                include: {
                    course: {
                        select: { name: true, code: true, color: true },
                    },
                },
                orderBy: { date: 'desc' },
            });
        });
    });

    describe('markAttendance', () => {
        it('should create new attendance record', async () => {
            const attendanceData = {
                courseId: 'course_1',
                date: new Date('2024-01-15'),
                status: 'PRESENT',
                note: 'On time',
            };

            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                isActive: true,
            };

            const mockCreatedAttendance = {
                id: 'att_1',
                userId: 'user_123',
                ...attendanceData,
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);
            prisma.attendance.upsert.mockResolvedValue(mockCreatedAttendance);

            const result = await attendanceService.markAttendance('user_123', attendanceData);

            expect(result).toEqual(mockCreatedAttendance);
            expect(prisma.attendance.upsert).toHaveBeenCalledWith({
                where: {
                    userId_courseId_date: {
                        userId: 'user_123',
                        courseId: 'course_1',
                        date: attendanceData.date,
                    },
                },
                update: {
                    status: 'PRESENT',
                    note: 'On time',
                },
                create: {
                    userId: 'user_123',
                    courseId: 'course_1',
                    date: attendanceData.date,
                    status: 'PRESENT',
                    note: 'On time',
                },
                include: {
                    course: {
                        select: { name: true, code: true, color: true },
                    },
                },
            });
        });

        it('should update existing attendance record', async () => {
            const attendanceData = {
                courseId: 'course_1',
                date: new Date('2024-01-15'),
                status: 'LATE',
                note: 'Traffic jam',
            };

            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                isActive: true,
            };

            const mockUpdatedAttendance = {
                id: 'att_1',
                userId: 'user_123',
                ...attendanceData,
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);
            prisma.attendance.upsert.mockResolvedValue(mockUpdatedAttendance);

            const result = await attendanceService.markAttendance('user_123', attendanceData);

            expect(result).toEqual(mockUpdatedAttendance);
        });

        it('should throw error when course not found', async () => {
            const attendanceData = {
                courseId: 'course_1',
                date: new Date('2024-01-15'),
                status: 'PRESENT',
            };

            prisma.course.findUnique.mockResolvedValue(null);

            await expect(attendanceService.markAttendance('user_123', attendanceData))
                .rejects.toThrow('Course not found or access denied');
        });

        it('should throw error for invalid attendance status', async () => {
            const attendanceData = {
                courseId: 'course_1',
                date: new Date('2024-01-15'),
                status: 'INVALID_STATUS',
            };

            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                isActive: true,
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);

            await expect(attendanceService.markAttendance('user_123', attendanceData))
                .rejects.toThrow('Invalid attendance status');
        });
    });

    describe('getAttendanceStatistics', () => {
        it('should return comprehensive statistics for course', async () => {
            const mockGroupedData = [
                { status: 'PRESENT', _count: { status: 8 } },
                { status: 'ABSENT', _count: { status: 2 } },
                { status: 'LATE', _count: { status: 1 } },
                { status: 'EXCUSED', _count: { status: 1 } },
            ];

            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                name: 'Mathematics',
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);
            prisma.attendance.groupBy.mockResolvedValue(mockGroupedData);

            const result = await attendanceService.getAttendanceStatistics('user_123', 'course_1');

            expect(result).toEqual({
                courseId: 'course_1',
                courseName: 'Mathematics',
                totalClasses: 12,
                present: 8,
                absent: 2,
                late: 1,
                excused: 1,
                attendanceRate: 75.0, // (8+1) / 12 * 100
                presentRate: 66.67, // 8 / 12 * 100
                statistics: {
                    PRESENT: 8,
                    ABSENT: 2,
                    LATE: 1,
                    EXCUSED: 1,
                },
            });
        });

        it('should handle course with no attendance records', async () => {
            const mockCourse = {
                id: 'course_1',
                userId: 'user_123',
                name: 'Mathematics',
            };

            prisma.course.findUnique.mockResolvedValue(mockCourse);
            prisma.attendance.groupBy.mockResolvedValue([]);

            const result = await attendanceService.getAttendanceStatistics('user_123', 'course_1');

            expect(result).toEqual({
                courseId: 'course_1',
                courseName: 'Mathematics',
                totalClasses: 0,
                present: 0,
                absent: 0,
                late: 0,
                excused: 0,
                attendanceRate: 0,
                presentRate: 0,
                statistics: {
                    PRESENT: 0,
                    ABSENT: 0,
                    LATE: 0,
                    EXCUSED: 0,
                },
            });
        });

        it('should throw error when course not found', async () => {
            prisma.course.findUnique.mockResolvedValue(null);

            await expect(attendanceService.getAttendanceStatistics('user_123', 'course_1'))
                .rejects.toThrow('Course not found or access denied');
        });
    });

    describe('getAttendanceByDateRange', () => {
        it('should return attendance records within date range', async () => {
            const startDate = new Date('2024-01-01');
            const endDate = new Date('2024-01-31');

            const mockAttendanceRecords = [
                {
                    id: 'att_1',
                    date: new Date('2024-01-15'),
                    status: 'PRESENT',
                },
                {
                    id: 'att_2',
                    date: new Date('2024-01-16'),
                    status: 'ABSENT',
                },
            ];

            prisma.attendance.findMany.mockResolvedValue(mockAttendanceRecords);

            const result = await attendanceService.getAttendanceByDateRange(
                'user_123',
                startDate,
                endDate
            );

            expect(result).toEqual(mockAttendanceRecords);
            expect(prisma.attendance.findMany).toHaveBeenCalledWith({
                where: {
                    userId: 'user_123',
                    date: {
                        gte: startDate,
                        lte: endDate,
                    },
                },
                include: {
                    course: {
                        select: { name: true, code: true, color: true },
                    },
                },
                orderBy: { date: 'desc' },
            });
        });
    });

    describe('getWeeklyAttendanceSummary', () => {
        it('should return weekly summary with all days', async () => {
            const mockAttendanceRecords = [
                { date: new Date('2024-01-15'), status: 'PRESENT' }, // Monday
                { date: new Date('2024-01-16'), status: 'ABSENT' },  // Tuesday
                { date: new Date('2024-01-17'), status: 'LATE' },    // Wednesday
            ];

            prisma.attendance.findMany.mockResolvedValue(mockAttendanceRecords);

            const result = await attendanceService.getWeeklyAttendanceSummary(
                'user_123',
                new Date('2024-01-15') // Monday
            );

            expect(result).toHaveProperty('weekStart');
            expect(result).toHaveProperty('weekEnd');
            expect(result).toHaveProperty('dailySummary');
            expect(result.dailySummary).toHaveLength(7); // All 7 days of week
            expect(result.totalClasses).toBe(3);
            expect(result.attendanceRate).toBeGreaterThan(0);
        });
    });
}); 