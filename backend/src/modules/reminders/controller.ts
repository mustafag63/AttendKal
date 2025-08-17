import { Response } from 'express';
import { prisma } from '@src/lib/prisma';
import { AppError, asyncHandler } from '@src/middlewares/error';
import { AuthenticatedRequest } from '@src/middlewares/auth';
import { CreateReminderInput, UpdateReminderInput } from '@src/lib/courseValidations';

export const getReminders = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const reminders = await prisma.reminder.findMany({
            where: { userId },
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
            orderBy: { createdAt: 'desc' },
        });

        res.json({
            success: true,
            data: { reminders },
        });
    }
);

export const getReminder = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const reminder = await prisma.reminder.findFirst({
            where: { id, userId },
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

        if (!reminder) {
            throw new AppError('Reminder not found', 404);
        }

        res.json({
            success: true,
            data: { reminder },
        });
    }
);

export const createReminder = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const reminderData = req.body as CreateReminderInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // If courseId is provided, check if course exists and belongs to user
        if (reminderData.courseId) {
            const course = await prisma.course.findFirst({
                where: { id: reminderData.courseId, userId },
            });

            if (!course) {
                throw new AppError('Course not found', 404);
            }
        }

        const reminder = await prisma.reminder.create({
            data: {
                ...reminderData,
                userId,
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
            data: { reminder },
            message: 'Reminder created successfully',
        });
    }
);

export const updateReminder = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;
        const updateData = req.body as UpdateReminderInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if reminder exists and belongs to user
        const existingReminder = await prisma.reminder.findFirst({
            where: { id, userId },
        });

        if (!existingReminder) {
            throw new AppError('Reminder not found', 404);
        }

        // If courseId is being updated, check if course exists and belongs to user
        if (updateData.courseId) {
            const course = await prisma.course.findFirst({
                where: { id: updateData.courseId, userId },
            });

            if (!course) {
                throw new AppError('Course not found', 404);
            }
        }

        const reminder = await prisma.reminder.update({
            where: { id },
            data: updateData,
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

        res.json({
            success: true,
            data: { reminder },
            message: 'Reminder updated successfully',
        });
    }
);

export const deleteReminder = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { id } = req.params;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Check if reminder exists and belongs to user
        const existingReminder = await prisma.reminder.findFirst({
            where: { id, userId },
        });

        if (!existingReminder) {
            throw new AppError('Reminder not found', 404);
        }

        await prisma.reminder.delete({
            where: { id },
        });

        res.json({
            success: true,
            message: 'Reminder deleted successfully',
        });
    }
);
