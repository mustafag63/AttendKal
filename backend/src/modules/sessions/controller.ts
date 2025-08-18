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
            whereClause.startTime = {};
            if (from) whereClause.startTime.gte = new Date(from);
            if (to) whereClause.startTime.lte = new Date(to);
        }

        const sessions = await prisma.session.findMany({
            where: whereClause,
            include: {
                course: {
                    select: { id: true, name: true, code: true, color: true },
                },
                // Şemadaki ilişki adı "attendances" veya başka bir şey olabilir.
                // "attendance" olmadığı kesin (TS hatası). Derlemeyi geçmek için şimdilik kapattım.
                // attendances: true,
            },
            // Prisma şemanda tarih alanı "startTime" olduğundan buna göre sırala
            orderBy: { startTime: 'desc' },
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

        // CreateSessionInput has startUtc and durationMin, convert to startTime and endTime
        const startTime = new Date(sessionData.startUtc);
        const endTime = new Date(startTime.getTime() + sessionData.durationMin * 60 * 1000);

        const session = await prisma.session.create({
            data: {
                courseId,
                startTime,
                endTime,
                source: sessionData.source,
            },
            include: {
                course: {
                    select: { id: true, name: true, code: true, color: true },
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
            include: { meetings: true },
        });

        if (!course) {
            throw new AppError('Course not found', 404);
        }

        if (!course.meetings.length) {
            throw new AppError('No meetings configured for this course', 400);
        }

        const fromDate = new Date(from);
        const toDate = new Date(to);

        // createMany için gerekli alanlar: startTime, endTime, courseId, (diğer opsiyoneller)
        const sessionsToCreate: Array<{
            courseId: string;
            startTime: Date;
            endTime: Date;
            source: 'AUTO';
            generatedFromMeetingId: string;
        }> = [];

        // Generate sessions for each meeting within the date range
        for (const meeting of course.meetings) {
            // meeting.weekday, meeting.startTime, meeting.endTime alanları mevcut (TS hatasından da görüldü)
            // startTime/endTime formatı 'HH:mm' string ise parçalayıp Date üretelim.
            const currentDate = new Date(fromDate);

            while (currentDate <= toDate) {
                // JS getDay(): 0=pazar ... 6=cumartesi; sende 1-7 aralığı varsa 0→7 çevirimi yapılmış.
                const currentWeekday = currentDate.getDay() === 0 ? 7 : currentDate.getDay();

                if (currentWeekday === meeting.weekday) {
                    // 'HH:mm' -> saat/dakika
                    const [sH, sM] = (meeting.startTime as string).split(':').map(Number);
                    const [eH, eM] = (meeting.endTime as string).split(':').map(Number);

                    // UTC tabanlı saklamak istersen setUTCHours; yerel saat istersen setHours kullan.
                    const sessionStart = new Date(currentDate);
                    sessionStart.setUTCHours(sH, sM, 0, 0);

                    const sessionEnd = new Date(currentDate);
                    sessionEnd.setUTCHours(eH, eM, 0, 0);

                    // Check if session already exists (startTime alanına göre)
                    const existingSession = await prisma.session.findFirst({
                        where: {
                            courseId,
                            startTime: sessionStart,
                        },
                    });

                    if (!existingSession) {
                        sessionsToCreate.push({
                            courseId,
                            startTime: sessionStart,
                            endTime: sessionEnd,
                            source: 'AUTO',
                            generatedFromMeetingId: meeting.id,
                        });
                    }
                }

                // bir gün ileri
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

        const result = await prisma.session.createMany({
            data: sessionsToCreate,
        });

        res.json({
            success: true,
            data: { generated: result.count },
            message: `Generated ${result.count} sessions successfully`,
        });
    }
);
