import { Response } from 'express';
import { prisma } from '@src/lib/prisma';
import { AppError, asyncHandler } from '@src/middlewares/error';
import { AuthenticatedRequest } from '@src/middlewares/auth';
import { MarkAttendanceInput } from '@src/lib/courseValidations';

export const markAttendance = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { sessionId } = req.params;
        const { status, note } = req.body as MarkAttendanceInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if session exists and belongs to user's course
        const session = await prisma.session.findFirst({
            where: {
                id: sessionId,
                course: { userId },
            },
            include: {
                course: {
                    select: {
                        id: true,
                        name: true,
                        maxAbsences: true,
                    },
                },
                attendanceRecords: true,
            },
        });

        if (!session) {
            throw new AppError('Session not found', 404);
        }

        // Create or update attendance
        const attendance = await prisma.attendance.upsert({
            where: {
                userId_sessionId: {
                    userId,
                    sessionId
                }
            },
            create: {
                userId,
                sessionId,
                status: status as any,
                note: note,
            },
            update: {
                status: status as any,
                note: note,
                updatedAt: new Date(),
            },
            include: {
                session: {
                    include: {
                        course: {
                            select: {
                                id: true,
                                name: true,
                                maxAbsences: true,
                            },
                        },
                    },
                },
            },
        });

        // Calculate current absence statistics
        const absentCount = await prisma.attendance.count({
            where: {
                session: { courseId: session.courseId },
                status: 'ABSENT',
            },
        });

        const remainingAbsences = Math.max(0, session.course.maxAbsences - absentCount);
        const lastStrike = remainingAbsences === 1;

        res.json({
            success: true,
            data: {
                attendance,
                stats: {
                    absentCount,
                    remainingAbsences,
                    lastStrike,
                },
            },
            message: 'Attendance marked successfully',
        });
    }
);

export const getAttendance = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { sessionId } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if session exists and belongs to user's course
        const session = await prisma.session.findFirst({
            where: {
                id: sessionId,
                course: { userId },
            },
            include: {
                course: {
                    select: {
                        id: true,
                        name: true,
                        maxAbsences: true,
                    },
                },
                attendanceRecords: true,
            },
        });

        if (!session) {
            throw new AppError('Session not found', 404);
        }

        res.json({
            success: true,
            data: {
                session,
                attendance: session.attendanceRecords,
            },
        });
    }
);
