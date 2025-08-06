import { prisma } from '../utils/prisma.js';
import { AppError } from '../middleware/errorHandler.js';

export class AttendanceService {
    // Mark attendance for a course
    static async markAttendance(userId, attendanceData) {
        const { courseId, date, status, note } = attendanceData;

        // Validate attendance status
        const validStatuses = ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'];
        if (!validStatuses.includes(status)) {
            throw new AppError('Invalid attendance status', 400);
        }

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: {
                id: courseId,
                userId,
                isActive: true,
            },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        // Parse and validate date
        const attendanceDate = new Date(date);
        if (isNaN(attendanceDate.getTime())) {
            throw new AppError('Invalid date format', 400);
        }

        // Check if attendance already exists for this date
        const existingAttendance = await prisma.attendance.findFirst({
            where: {
                userId,
                courseId,
                date: {
                    gte: new Date(attendanceDate.setHours(0, 0, 0, 0)),
                    lt: new Date(attendanceDate.setHours(23, 59, 59, 999)),
                },
            },
        });

        let attendance;

        if (existingAttendance) {
            // Update existing attendance
            attendance = await prisma.attendance.update({
                where: { id: existingAttendance.id },
                data: {
                    status,
                    note: note?.trim(),
                },
                include: {
                    course: {
                        select: {
                            id: true,
                            name: true,
                            code: true,
                        },
                    },
                },
            });
        } else {
            // Create new attendance record
            attendance = await prisma.attendance.create({
                data: {
                    userId,
                    courseId,
                    date: new Date(attendanceDate.setHours(12, 0, 0, 0)), // Set to noon
                    status,
                    note: note?.trim(),
                },
                include: {
                    course: {
                        select: {
                            id: true,
                            name: true,
                            code: true,
                        },
                    },
                },
            });
        }

        return attendance;
    }

    // Get attendance records with filters
    static async getAttendance(userId, options = {}) {
        const {
            courseId,
            startDate,
            endDate,
            status,
            page = 1,
            limit = 10,
        } = options;

        const skip = (page - 1) * limit;

        const where = {
            userId,
            ...(courseId && { courseId }),
            ...(status && { status }),
            ...(startDate || endDate) && {
                date: {
                    ...(startDate && { gte: new Date(startDate) }),
                    ...(endDate && { lte: new Date(endDate) }),
                },
            },
        };

        const [attendances, total] = await Promise.all([
            prisma.attendance.findMany({
                where,
                include: {
                    course: {
                        select: {
                            id: true,
                            name: true,
                            code: true,
                            color: true,
                        },
                    },
                },
                orderBy: { date: 'desc' },
                skip,
                take: limit,
            }),
            prisma.attendance.count({ where }),
        ]);

        return {
            attendances,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
                hasNext: page * limit < total,
                hasPrev: page > 1,
            },
        };
    }

    // Get attendance by course
    static async getCourseAttendance(userId, courseId, options = {}) {
        const { startDate, endDate, page = 1, limit = 20 } = options;

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: {
                id: courseId,
                userId,
                isActive: true,
            },
            include: {
                schedule: true,
            },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        const where = {
            userId,
            courseId,
            ...(startDate || endDate) && {
                date: {
                    ...(startDate && { gte: new Date(startDate) }),
                    ...(endDate && { lte: new Date(endDate) }),
                },
            },
        };

        const skip = (page - 1) * limit;

        const [attendances, total] = await Promise.all([
            prisma.attendance.findMany({
                where,
                orderBy: { date: 'desc' },
                skip,
                take: limit,
            }),
            prisma.attendance.count({ where }),
        ]);

        return {
            course: {
                id: course.id,
                name: course.name,
                code: course.code,
                instructor: course.instructor,
                schedule: course.schedule,
            },
            attendances,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
                hasNext: page * limit < total,
                hasPrev: page > 1,
            },
        };
    }

    // Get attendance statistics for a course
    static async getCourseAttendanceStats(userId, courseId, options = {}) {
        const { startDate, endDate } = options;

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: {
                id: courseId,
                userId,
                isActive: true,
            },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        const where = {
            userId,
            courseId,
            ...(startDate || endDate) && {
                date: {
                    ...(startDate && { gte: new Date(startDate) }),
                    ...(endDate && { lte: new Date(endDate) }),
                },
            },
        };

        // Get attendance counts by status
        const statusCounts = await prisma.attendance.groupBy({
            by: ['status'],
            where,
            _count: {
                status: true,
            },
        });

        // Get recent attendance trend (last 30 days)
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const recentAttendance = await prisma.attendance.findMany({
            where: {
                ...where,
                date: { gte: thirtyDaysAgo },
            },
            orderBy: { date: 'asc' },
            select: {
                date: true,
                status: true,
            },
        });

        // Calculate statistics
        const totalClasses = statusCounts.reduce((sum, item) => sum + item._count.status, 0);
        const presentCount = statusCounts.find(s => s.status === 'PRESENT')?._count.status || 0;
        const lateCount = statusCounts.find(s => s.status === 'LATE')?._count.status || 0;
        const absentCount = statusCounts.find(s => s.status === 'ABSENT')?._count.status || 0;
        const excusedCount = statusCounts.find(s => s.status === 'EXCUSED')?._count.status || 0;

        const attendedClasses = presentCount + lateCount;
        const attendanceRate = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;

        // Calculate streak (consecutive present/late days)
        const currentStreak = this._calculateAttendanceStreak(recentAttendance);

        return {
            course: {
                id: course.id,
                name: course.name,
                code: course.code,
            },
            period: {
                startDate,
                endDate,
                totalClasses,
            },
            statistics: {
                presentCount,
                lateCount,
                absentCount,
                excusedCount,
                attendedClasses,
                attendanceRate: Math.round(attendanceRate * 100) / 100,
                currentStreak,
            },
            breakdown: statusCounts.map(item => ({
                status: item.status,
                count: item._count.status,
                percentage: totalClasses > 0
                    ? Math.round((item._count.status / totalClasses) * 10000) / 100
                    : 0,
            })),
            trend: recentAttendance.map(record => ({
                date: record.date.toISOString().split('T')[0],
                status: record.status,
            })),
        };
    }

    // Get user's overall attendance summary
    static async getUserAttendanceSummary(userId, options = {}) {
        const { startDate, endDate } = options;

        const where = {
            userId,
            ...(startDate || endDate) && {
                date: {
                    ...(startDate && { gte: new Date(startDate) }),
                    ...(endDate && { lte: new Date(endDate) }),
                },
            },
        };

        // Get attendance by course
        const courseStats = await prisma.attendance.groupBy({
            by: ['courseId'],
            where,
            _count: {
                status: true,
            },
        });

        // Get overall statistics
        const overallStats = await prisma.attendance.groupBy({
            by: ['status'],
            where,
            _count: {
                status: true,
            },
        });

        // Get course details
        const courseIds = courseStats.map(stat => stat.courseId);
        const courses = await prisma.course.findMany({
            where: {
                id: { in: courseIds },
                userId,
            },
            select: {
                id: true,
                name: true,
                code: true,
                color: true,
            },
        });

        // Calculate totals
        const totalClasses = overallStats.reduce((sum, item) => sum + item._count.status, 0);
        const presentCount = overallStats.find(s => s.status === 'PRESENT')?._count.status || 0;
        const lateCount = overallStats.find(s => s.status === 'LATE')?._count.status || 0;
        const attendanceRate = totalClasses > 0
            ? ((presentCount + lateCount) / totalClasses) * 100
            : 0;

        return {
            period: { startDate, endDate },
            overall: {
                totalClasses,
                attendanceRate: Math.round(attendanceRate * 100) / 100,
                breakdown: overallStats.map(item => ({
                    status: item.status,
                    count: item._count.status,
                })),
            },
            byCourse: courseStats.map(stat => {
                const course = courses.find(c => c.id === stat.courseId);
                return {
                    course,
                    totalClasses: stat._count.status,
                };
            }),
        };
    }

    // Delete attendance record
    static async deleteAttendance(userId, attendanceId) {
        const attendance = await prisma.attendance.findFirst({
            where: {
                id: attendanceId,
                userId,
            },
        });

        if (!attendance) {
            throw new AppError('Attendance record not found', 404);
        }

        await prisma.attendance.delete({
            where: { id: attendanceId },
        });

        return { message: 'Attendance record deleted successfully' };
    }

    // Private helper method to calculate attendance streak
    static _calculateAttendanceStreak(attendanceRecords) {
        if (attendanceRecords.length === 0) return 0;

        let streak = 0;
        const sortedRecords = attendanceRecords.sort((a, b) => new Date(b.date) - new Date(a.date));

        for (const record of sortedRecords) {
            if (record.status === 'PRESENT' || record.status === 'LATE') {
                streak++;
            } else {
                break;
            }
        }

        return streak;
    }
} 