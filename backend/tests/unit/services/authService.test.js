import { jest } from '@jest/globals';
import { AuthService } from '../../../src/services/authService.js';
import { AppError } from '../../../src/middleware/errorHandler.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// Mock dependencies
jest.mock('../../../src/utils/prisma.js', () => ({
    prisma: {
        user: {
            findUnique: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
        },
        subscription: {
            create: jest.fn(),
        },
        userSession: {
            create: jest.fn(),
            findFirst: jest.fn(),
            update: jest.fn(),
            updateMany: jest.fn(),
        },
        $transaction: jest.fn(),
    },
}));

jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

import { prisma } from '../../../src/utils/prisma.js';

describe('AuthService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('generateTokens', () => {
        it('should generate access and refresh tokens', () => {
            const userId = 'user123';
            const mockAccessToken = 'access-token';
            const mockRefreshToken = 'refresh-token';

            jwt.sign
                .mockReturnValueOnce(mockAccessToken)
                .mockReturnValueOnce(mockRefreshToken);

            const result = AuthService.generateTokens(userId);

            expect(jwt.sign).toHaveBeenCalledTimes(2);
            expect(jwt.sign).toHaveBeenNthCalledWith(
                1,
                { id: userId },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRE }
            );
            expect(jwt.sign).toHaveBeenNthCalledWith(
                2,
                { id: userId },
                process.env.JWT_REFRESH_SECRET,
                { expiresIn: process.env.JWT_REFRESH_EXPIRE }
            );

            expect(result).toEqual({
                accessToken: mockAccessToken,
                refreshToken: mockRefreshToken,
            });
        });
    });

    describe('registerUser', () => {
        const userData = {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
        };

        it('should register a new user successfully', async () => {
            const hashedPassword = 'hashed-password';
            const newUser = {
                id: 'user123',
                ...userData,
                password: hashedPassword,
                role: 'STUDENT',
            };

            prisma.user.findUnique.mockResolvedValue(null); // User doesn't exist
            bcrypt.hash.mockResolvedValue(hashedPassword);
            prisma.$transaction.mockResolvedValue(newUser);

            const result = await AuthService.registerUser(userData);

            expect(prisma.user.findUnique).toHaveBeenCalledWith({
                where: { email: userData.email.toLowerCase() },
            });
            expect(bcrypt.hash).toHaveBeenCalledWith(userData.password, 4);
            expect(prisma.$transaction).toHaveBeenCalled();
            expect(result).toEqual(newUser);
        });

        it('should throw error if user already exists', async () => {
            prisma.user.findUnique.mockResolvedValue({ id: 'existing-user' });

            await expect(AuthService.registerUser(userData)).rejects.toThrow(
                new AppError('User with this email already exists', 400)
            );

            expect(bcrypt.hash).not.toHaveBeenCalled();
            expect(prisma.$transaction).not.toHaveBeenCalled();
        });
    });

    describe('authenticateUser', () => {
        const credentials = {
            email: 'john@example.com',
            password: 'password123',
        };

        it('should authenticate user successfully', async () => {
            const user = {
                id: 'user123',
                email: credentials.email,
                password: 'hashed-password',
                isActive: true,
            };

            prisma.user.findUnique.mockResolvedValue(user);
            bcrypt.compare.mockResolvedValue(true);

            const result = await AuthService.authenticateUser(credentials);

            expect(prisma.user.findUnique).toHaveBeenCalledWith({
                where: { email: credentials.email.toLowerCase() },
            });
            expect(bcrypt.compare).toHaveBeenCalledWith(
                credentials.password,
                user.password
            );
            expect(result).toEqual(user);
        });

        it('should throw error for invalid credentials', async () => {
            prisma.user.findUnique.mockResolvedValue(null);

            await expect(AuthService.authenticateUser(credentials)).rejects.toThrow(
                new AppError('Incorrect email or password', 401)
            );
        });

        it('should throw error for inactive user', async () => {
            const user = {
                id: 'user123',
                email: credentials.email,
                password: 'hashed-password',
                isActive: false,
            };

            prisma.user.findUnique.mockResolvedValue(user);
            bcrypt.compare.mockResolvedValue(true);

            await expect(AuthService.authenticateUser(credentials)).rejects.toThrow(
                new AppError('Your account has been deactivated', 401)
            );
        });
    });

    describe('createSession', () => {
        it('should create user session successfully', async () => {
            const userId = 'user123';
            const refreshToken = 'refresh-token';
            const req = {
                headers: { 'user-agent': 'test-agent' },
                ip: '127.0.0.1',
            };

            const session = {
                id: 'session123',
                userId,
                refreshToken,
                userAgent: req.headers['user-agent'],
                ipAddress: req.ip,
            };

            prisma.userSession.create.mockResolvedValue(session);

            const result = await AuthService.createSession(userId, refreshToken, req);

            expect(prisma.userSession.create).toHaveBeenCalledWith({
                data: {
                    userId,
                    refreshToken,
                    userAgent: req.headers['user-agent'],
                    ipAddress: req.ip,
                    expiresAt: expect.any(Date),
                },
            });
            expect(result).toEqual(session);
        });
    });

    describe('refreshUserToken', () => {
        const refreshToken = 'refresh-token';

        it('should refresh token successfully', async () => {
            const decoded = { id: 'user123' };
            const session = {
                id: 'session123',
                user: { id: 'user123', email: 'john@example.com' },
            };
            const newTokens = {
                accessToken: 'new-access-token',
                refreshToken: 'new-refresh-token',
            };

            jwt.verify.mockReturnValue(decoded);
            prisma.userSession.findFirst.mockResolvedValue(session);
            prisma.userSession.update.mockResolvedValue({});

            // Mock the generateTokens method
            const generateTokensSpy = jest
                .spyOn(AuthService, 'generateTokens')
                .mockReturnValue(newTokens);

            const result = await AuthService.refreshUserToken(refreshToken);

            expect(jwt.verify).toHaveBeenCalledWith(
                refreshToken,
                process.env.JWT_REFRESH_SECRET
            );
            expect(prisma.userSession.findFirst).toHaveBeenCalled();
            expect(generateTokensSpy).toHaveBeenCalledWith(session.user.id);
            expect(prisma.userSession.update).toHaveBeenCalled();

            expect(result).toEqual({
                user: session.user,
                accessToken: newTokens.accessToken,
                refreshToken: newTokens.refreshToken,
            });

            generateTokensSpy.mockRestore();
        });

        it('should throw error for invalid refresh token', async () => {
            const decoded = { id: 'user123' };

            jwt.verify.mockReturnValue(decoded);
            prisma.userSession.findFirst.mockResolvedValue(null);

            await expect(AuthService.refreshUserToken(refreshToken)).rejects.toThrow(
                new AppError('Invalid or expired refresh token', 401)
            );
        });
    });

    describe('updateUserPassword', () => {
        const userId = 'user123';
        const currentPassword = 'oldpassword';
        const newPassword = 'newpassword123';

        it('should update password successfully', async () => {
            const user = {
                id: userId,
                password: 'old-hashed-password',
            };
            const newHashedPassword = 'new-hashed-password';

            prisma.user.findUnique.mockResolvedValue(user);
            bcrypt.compare.mockResolvedValue(true);
            bcrypt.hash.mockResolvedValue(newHashedPassword);
            prisma.$transaction.mockResolvedValue([{}, {}]);

            await AuthService.updateUserPassword(userId, currentPassword, newPassword);

            expect(prisma.user.findUnique).toHaveBeenCalledWith({
                where: { id: userId },
            });
            expect(bcrypt.compare).toHaveBeenCalledWith(
                currentPassword,
                user.password
            );
            expect(bcrypt.hash).toHaveBeenCalledWith(newPassword, 4);
            expect(prisma.$transaction).toHaveBeenCalled();
        });

        it('should throw error for incorrect current password', async () => {
            const user = {
                id: userId,
                password: 'old-hashed-password',
            };

            prisma.user.findUnique.mockResolvedValue(user);
            bcrypt.compare.mockResolvedValue(false);

            await expect(
                AuthService.updateUserPassword(userId, currentPassword, newPassword)
            ).rejects.toThrow(new AppError('Current password is incorrect', 401));

            expect(bcrypt.hash).not.toHaveBeenCalled();
            expect(prisma.$transaction).not.toHaveBeenCalled();
        });
    });
}); 