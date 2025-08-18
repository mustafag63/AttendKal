import { Response } from 'express';
import { prisma } from '@src/lib/prisma';
import { AppError, asyncHandler } from '@src/middlewares/error';
import { AuthenticatedRequest } from '@src/middlewares/auth';
import {
    CreateCourseInput,
    UpdateCourseInput,
    CreateMeetingInput,
    // CreateSessionInput  // kullanılmıyor → sildik
} from '@src/lib/courseValidations';

// Helper function to calculate end time
const calculateEndTime = (startTime: string, durationMinutes: number): string => {
    const [hours, minutes] = startTime.split(':').map(Number);
    const startDate = new Date();
    startDate.setHours(hours, minutes, 0, 0);

    const endDate = new Date(startDate.getTime() + durationMinutes * 60000);

    const hh = endDate.getHours().toString().padStart(2, '0');
    const mm = endDate.getMinutes().toString().padStart(2, '0');
    return `${hh}:${mm}`;
};

// (Opsiyonel) iki HH:mm arasındaki dakika farkını hesaplamak için
const diffMinutes = (start: string, end: string) => {
    const [sh, sm] = start.split(':').map(Number);
    const [eh, em] = end.split(':').map(Number);
    return eh * 60 + em - (sh * 60 + sm);
};

// Course Controllers
export const getCourses = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const courses = await prisma.course.findMany({
            where: { userId },
            include: {
                meetings: true,
                sessions: {
                    include: {
                        attendanceRecords: true,
                    },
                    orderBy: { startTime: 'desc' },
                    take: 5, // Latest 5 sessions per course
                },
                _count: {
                    select: {
                        sessions: true,
                    },
                },
            },
            orderBy: { name: 'asc' },
        });

        // Calculate attendance statistics for each course
        const coursesWithStats = await Promise.all(
            courses.map(async (course) => {
                const absentCount = await prisma.attendance.count({
                    where: {
                        session: { courseId: course.id },
                        status: 'ABSENT',
                    },
                });

                const remainingAbsences = Math.max(0, course.maxAbsences - absentCount);
                const lastStrike = remainingAbsences === 1;

                return {
                    ...course,
                    stats: {
                        absentCount,
                        remainingAbsences,
                        lastStrike,
                        totalSessions: course.sessions?.length || 0,
                    },
                };
            })
        );

        res.json({
            success: true,
            data: { courses: coursesWithStats },
        });
    }
);

export const getCourse = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const course = await prisma.course.findFirst({
            where: { id, userId },
            include: {
                meetings: {
                    orderBy: { weekday: 'asc' },
                },
                sessions: {
                    include: {
                        attendanceRecords: true,
                    },
                    orderBy: { startTime: 'desc' },
                },
                _count: {
                    select: {
                        sessions: true,
                    },
                },
            },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        // Calculate attendance statistics
        const absentCount = await prisma.attendance.count({
            where: {
                session: { courseId: course.id },
                status: 'ABSENT',
            },
        });

        const remainingAbsences = Math.max(0, course.maxAbsences - absentCount);
        const lastStrike = remainingAbsences === 1;

        res.json({
            success: true,
            data: {
                course: {
                    ...course,
                    stats: {
                        absentCount,
                        remainingAbsences,
                        lastStrike,
                        totalSessions: course.sessions?.length || 0,
                    },
                },
            },
        });
    }
);

export const createCourse = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const courseData = req.body as CreateCourseInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const course = await prisma.course.create({
            data: {
                ...courseData,
                userId,
            },
            include: {
                meetings: true,
                _count: {
                    select: {
                        sessions: true,
                    },
                },
            },
        });

        res.status(201).json({
            success: true,
            data: { course },
            message: 'Course created successfully',
        });
    }
);

export const updateCourse = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;
        const updateData = req.body as UpdateCourseInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if course exists and belongs to user
        const existingCourse = await prisma.course.findFirst({
            where: { id, userId },
        });

        if (!existingCourse) {
            throw new AppError('Course not found', 404);
        }

        const course = await prisma.course.update({
            where: { id },
            data: updateData,
            include: {
                meetings: true,
                _count: {
                    select: {
                        sessions: true,
                    },
                },
            },
        });

        res.json({
            success: true,
            data: { course },
            message: 'Course updated successfully',
        });
    }
);

export const deleteCourse = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if course exists and belongs to user
        const existingCourse = await prisma.course.findFirst({
            where: { id, userId },
        });

        if (!existingCourse) {
            throw new AppError('Course not found', 404);
        }

        await prisma.course.delete({
            where: { id },
        });

        res.json({
            success: true,
            message: 'Course deleted successfully',
        });
    }
);

// Meeting Controllers
export const createMeeting = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id: courseId } = req.params;
        const meetingData = req.body as CreateMeetingInput; // artık { weekday, startTime, endTime, ... }

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: { id: courseId, userId },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        // 'HH:mm' inputlarıyla çalış: endTime yoksa 90 dk varsayalım
        const start = meetingData.startTime ?? '09:00';
        const end = meetingData.endTime ?? calculateEndTime(start, 90);

        // Eğer Prisma Meeting modelinde durationMinutes kolonu VARSA aşağıdaki satırı ekleyebilirsin:
        // const durationMinutes = diffMinutes(start, end);

        const meeting = await prisma.meeting.create({
            data: {
                courseId,
                weekday: meetingData.weekday,
                startTime: start,
                endTime: end,
                // durationMinutes, // ← şemanda varsa aç
                location: meetingData.location,
                note: meetingData.note,
            },
        });

        res.status(201).json({
            success: true,
            data: { meeting },
            message: 'Meeting created successfully',
        });
    }
);

export const deleteMeeting = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id: courseId, mid: meetingId } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: { id: courseId, userId },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        // Check if meeting exists and belongs to the course
        const meeting = await prisma.meeting.findFirst({
            where: { id: meetingId, courseId },
        });

        if (!meeting) {
            throw new AppError('Meeting not found', 404);
        }

        await prisma.meeting.delete({
            where: { id: meetingId },
        });

        res.json({
            success: true,
            message: 'Meeting deleted successfully',
        });
    }
);
