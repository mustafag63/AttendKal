import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '@src/lib/prisma';
import { config } from '@src/config/env';
import { AppError, asyncHandler } from '@src/middlewares/error';
import { AuthenticatedRequest } from '@src/middlewares/auth';
import { RegisterInput, LoginInput, ChangePasswordInput } from '@src/lib/validations';

export const register = asyncHandler(
    async (req: Request<{}, {}, RegisterInput>, res: Response): Promise<void> => {
        const { email, password, username, timezone, locale } = req.body;

        // Check if user already exists
        const existingUser = await prisma.user.findFirst({
            where: {
                OR: [
                    { email },
                    ...(username ? [{ username }] : []),
                ],
            },
        });

        if (existingUser) {
            throw new AppError('User with this email or username already exists', 409);
        }

        // Hash password
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);

        // Create user
        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
                username: username || null,
                timezone: timezone || 'UTC',
                locale: locale || 'en',
                termsAcceptedAt: new Date(),
            },
            select: {
                id: true,
                email: true,
                username: true,
                timezone: true,
                locale: true,
                createdAt: true,
            },
        });

        // Generate JWT token
        const token = jwt.sign(
            {
                id: user.id,
                email: user.email,
                tokenVersion: 0
            },
            config.jwtSecret,
            { expiresIn: '30m' }
        );

        res.status(201).json({
            success: true,
            data: {
                user,
                token,
            },
            message: 'User registered successfully',
        });
    }
);

export const login = asyncHandler(
    async (req: Request<{}, {}, LoginInput>, res: Response): Promise<void> => {
        const { email, password } = req.body;

        // Find user by email
        const user = await prisma.user.findUnique({
            where: { email },
        });

        if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
            throw new AppError('Invalid email or password', 401);
        }

        // Update last login
        await prisma.user.update({
            where: { id: user.id },
            data: { lastLoginAt: new Date() },
        });

        // Generate JWT token
        const token = jwt.sign(
            {
                id: user.id,
                email: user.email,
                tokenVersion: user.refreshTokenVersion
            },
            config.jwtSecret,
            { expiresIn: '30m' }
        );

        res.json({
            success: true,
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    username: user.username,
                    timezone: user.timezone,
                    locale: user.locale,
                    emailVerifiedAt: user.emailVerifiedAt,
                    lastLoginAt: user.lastLoginAt,
                },
                token,
            },
            message: 'Login successful',
        });
    }
);

export const getProfile = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        const user = await prisma.user.findUnique({
            where: { id: userId },
            select: {
                id: true,
                email: true,
                username: true,
                timezone: true,
                locale: true,
                emailVerifiedAt: true,
                lastLoginAt: true,
                createdAt: true,
                updatedAt: true,
                marketingConsentAt: true,
                termsAcceptedAt: true,
            },
        });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        res.json({
            success: true,
            data: { user },
        });
    }
);

export const changePassword = asyncHandler(
    async (req: AuthenticatedRequest, res: Response): Promise<void> => {
        const userId = req.user?.id;
        const { currentPassword, newPassword } = req.body as ChangePasswordInput;

        if (!userId) {
            throw new AppError('User not authenticated', 401);
        }

        // Get user with password hash
        const user = await prisma.user.findUnique({
            where: { id: userId },
        });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Verify current password
        const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.passwordHash);
        if (!isCurrentPasswordValid) {
            throw new AppError('Current password is incorrect', 400);
        }

        // Hash new password
        const saltRounds = 12;
        const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

        // Update password and increment refresh token version (invalidates all existing tokens)
        await prisma.user.update({
            where: { id: userId },
            data: {
                passwordHash: newPasswordHash,
                refreshTokenVersion: user.refreshTokenVersion + 1,
            },
        });

        res.json({
            success: true,
            message: 'Password changed successfully. Please login again.',
        });
    }
);
