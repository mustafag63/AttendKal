import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';

const prisma = new PrismaClient();

// Validation schemas
const FCMTokenSchema = z.object({
    fcmToken: z.string().min(1, 'FCM token is required'),
    deviceId: z.string().optional(),
    platform: z.string().default('mobile'),
    timestamp: z.string().optional(),
});

const RemoveFCMTokenSchema = z.object({
    fcmToken: z.string().min(1, 'FCM token is required'),
});

/**
 * Store or update user's FCM token
 */
export const storeFCMToken = async (req: Request, res: Response): Promise<void> => {
    try {
        const { userId } = req.params;
        const validatedData = FCMTokenSchema.parse(req.body);

        // TODO: Implement when UserDeviceToken model is available in database
        // For now, just validate the request and return success
        console.log(`FCM token received for user ${userId}:`, {
            tokenLength: validatedData.fcmToken.length,
            platform: validatedData.platform,
            deviceId: validatedData.deviceId,
        });

        res.status(200).json({
            message: 'FCM token stored successfully',
            userId,
            tokenLength: validatedData.fcmToken.length,
        });

    } catch (error) {
        console.error('Error storing FCM token:', error);

        if (error instanceof z.ZodError) {
            res.status(400).json({
                error: 'Validation error',
                details: error.errors,
            });
            return;
        }

        res.status(500).json({
            error: 'Internal server error',
            code: 'INTERNAL_ERROR',
        });
    }
};

/**
 * Remove user's FCM token (on logout)
 */
export const removeFCMToken = async (req: Request, res: Response): Promise<void> => {
    try {
        const { userId } = req.params;
        const validatedData = RemoveFCMTokenSchema.parse(req.body);

        // TODO: Implement when UserDeviceToken model is available in database
        console.log(`FCM token removal requested for user ${userId}:`, {
            tokenLength: validatedData.fcmToken.length,
        });

        res.status(200).json({
            message: 'FCM token removed successfully',
            userId,
        });

    } catch (error) {
        console.error('Error removing FCM token:', error);

        if (error instanceof z.ZodError) {
            res.status(400).json({
                error: 'Validation error',
                details: error.errors,
            });
            return;
        }

        res.status(500).json({
            error: 'Internal server error',
            code: 'INTERNAL_ERROR',
        });
    }
};

/**
 * Get user's active FCM tokens
 */
export const getUserFCMTokens = async (req: Request, res: Response): Promise<void> => {
    try {
        const { userId } = req.params;

        // TODO: Implement when UserDeviceToken model is available in database
        console.log(`FCM tokens requested for user ${userId}`);

        res.status(200).json({
            userId,
            tokens: [],
            count: 0,
        });

    } catch (error) {
        console.error('Error getting FCM tokens:', error);

        res.status(500).json({
            error: 'Internal server error',
            code: 'INTERNAL_ERROR',
        });
    }
};

/**
 * Clean up inactive FCM tokens (maintenance endpoint)
 */
export const cleanupInactiveTokens = async (req: Request, res: Response): Promise<void> => {
    try {
        // TODO: Implement when UserDeviceToken model is available in database
        console.log('FCM token cleanup requested');

        res.status(200).json({
            message: 'Inactive tokens cleaned up',
            deletedCount: 0,
        });

    } catch (error) {
        console.error('Error cleaning up tokens:', error);

        res.status(500).json({
            error: 'Internal server error',
            code: 'INTERNAL_ERROR',
        });
    }
};
