import { Request, Response } from 'express';
import { prisma } from '@src/lib/prisma';
import { AppError, asyncHandler } from '@src/middlewares/error';
import { AuthenticatedRequest } from '@src/middlewares/auth';
import {
    CreateSessionInput,
    GenerateSessionsInput,
    GetSessionsInput
} from '@src/lib/courseValidations';

export const getSessions = asyncHandler(
    async (req: Request, res: Response): Promise<void> => {
        const { from, to, courseId } = req.query as GetSessionsInput;
        const userId = (req as AuthenticatedRequest).user?.id;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const whereClause: any = {
            course: { userId },
        };

        if (courseId) {
            whereClause.courseId = courseId;
        }

        if (from || to) {
            whereClause.dateTime = {};
            if (from) whereClause.dateTime.gte = new Date(from);
            if (to) whereClause.dateTime.lte = new Date(to);
        }

        const sessions = await prisma.session.findMany({
            where: whereClause,
            include: {
                course: {
                    select: {
                        id: true,
                        name: true,
                        code: true,
                        color: true,
                    },
                },
                attendance: true,
            },
            orderBy: { dateTime: 'desc' },
        });

        res.json({
            success: true,
            data: { sessions },
        });
    }
);

export const createSession = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { courseId } = req.params;
        const sessionData = req.body as CreateSessionInput;

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

        const session = await prisma.session.create({
            data: {
                courseId,
                dateTime: new Date(sessionData.startUtc),
                duration: sessionData.durationMin,
                source: sessionData.source,
            },
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
        });

        res.status(201).json({
            success: true,
            data: { session },
            message: 'Session created successfully',
        });
    }
);

export const generateSessions = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { courseId, from, to } = req.body as GenerateSessionsInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if course exists and belongs to user
        const course = await prisma.course.findFirst({
            where: { id: courseId, userId },
            include: {
                meetings: true,
            },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        if (!course.meetings.length) {
            throw new AppError('No meetings configured for this course', 400);
        }

        const fromDate = new Date(from);
        const toDate = new Date(to);
        const sessionsToCreate = [];

        // Generate sessions for each meeting within the date range
        for (const meeting of course.meetings) {
            const currentDate = new Date(fromDate);

            while (currentDate <= toDate) {
                // Check if current date matches the meeting weekday
                const currentWeekday = currentDate.getDay() === 0 ? 7 : currentDate.getDay();

                if (currentWeekday === meeting.weekday) {
                    // Parse time
                    const [hours, minutes] = meeting.startHHmm.split(':').map(Number);
                    const sessionStart = new Date(currentDate);
                    sessionStart.setUTCHours(hours, minutes, 0, 0);

                    // Check if session already exists
                    const existingSession = await prisma.session.findFirst({
                        where: {
                            courseId,
                            dateTime: sessionStart,
                        },
                    });

                    if (!existingSession) {
                        sessionsToCreate.push({
                            courseId,
                            dateTime: sessionStart,
                            duration: meeting.durationMin,
                            source: 'AUTO' as const,
                            meetingId: meeting.id,
                        });
                    }
                }

                currentDate.setDate(currentDate.getDate() + 1);
            }
        }

        if (sessionsToCreate.length === 0) {
            res.json({
                success: true,
                data: { sessions: [], generated: 0 },
                message: 'No new sessions to generate',
            });
            return;
        }

        const sessions = await prisma.session.createMany({
            data: sessionsToCreate,
        });

        res.json({
            success: true,
            data: { generated: sessions.count },
            message: `Generated ${sessions.count} sessions successfully`,
        });
    }
);
