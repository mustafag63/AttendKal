import { jest } from '@jest/globals';
import { subscriptionService } from '../../../src/services/subscriptionService.js';
import { prisma } from '../../../src/utils/prisma.js';

// Mock Prisma
jest.mock('../../../src/utils/prisma.js', () => ({
    prisma: {
        subscription: {
            findUnique: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
            findMany: jest.fn(),
        },
        user: {
            findUnique: jest.fn(),
            update: jest.fn(),
        },
    },
}));

describe('SubscriptionService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    describe('getSubscription', () => {
        it('should return user subscription when exists', async () => {
            const mockSubscription = {
                id: 'sub_123',
                userId: 'user_123',
                type: 'PRO',
                isActive: true,
                startDate: new Date(),
                endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
            };

            prisma.subscription.findUnique.mockResolvedValue(mockSubscription);

            const result = await subscriptionService.getSubscription('user_123');

            expect(result).toEqual(mockSubscription);
            expect(prisma.subscription.findUnique).toHaveBeenCalledWith({
                where: { userId: 'user_123' },
            });
        });

        it('should return null when subscription does not exist', async () => {
            prisma.subscription.findUnique.mockResolvedValue(null);

            const result = await subscriptionService.getSubscription('user_123');

            expect(result).toBeNull();
        });

        it('should throw error when database query fails', async () => {
            prisma.subscription.findUnique.mockRejectedValue(new Error('Database error'));

            await expect(subscriptionService.getSubscription('user_123'))
                .rejects.toThrow('Database error');
        });
    });

    describe('createSubscription', () => {
        it('should create new subscription successfully', async () => {
            const subscriptionData = {
                userId: 'user_123',
                type: 'PRO',
                stripeCustomerId: 'cus_123',
                stripeSubscriptionId: 'sub_123',
            };

            const mockCreatedSubscription = {
                id: 'sub_456',
                ...subscriptionData,
                isActive: true,
                startDate: new Date(),
                endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
            };

            prisma.subscription.create.mockResolvedValue(mockCreatedSubscription);

            const result = await subscriptionService.createSubscription(subscriptionData);

            expect(result).toEqual(mockCreatedSubscription);
            expect(prisma.subscription.create).toHaveBeenCalledWith({
                data: expect.objectContaining({
                    userId: 'user_123',
                    type: 'PRO',
                    stripeCustomerId: 'cus_123',
                    stripeSubscriptionId: 'sub_123',
                    isActive: true,
                }),
            });
        });

        it('should handle duplicate subscription creation', async () => {
            const subscriptionData = {
                userId: 'user_123',
                type: 'PRO',
            };

            const error = new Error('Unique constraint violation');
            error.code = 'P2002';
            prisma.subscription.create.mockRejectedValue(error);

            await expect(subscriptionService.createSubscription(subscriptionData))
                .rejects.toThrow('Unique constraint violation');
        });
    });

    describe('upgradeSubscription', () => {
        it('should upgrade existing subscription to PRO', async () => {
            const mockExistingSubscription = {
                id: 'sub_123',
                userId: 'user_123',
                type: 'FREE',
                isActive: true,
            };

            const mockUpdatedSubscription = {
                ...mockExistingSubscription,
                type: 'PRO',
                stripeCustomerId: 'cus_123',
                stripeSubscriptionId: 'sub_123',
            };

            prisma.subscription.findUnique.mockResolvedValue(mockExistingSubscription);
            prisma.subscription.update.mockResolvedValue(mockUpdatedSubscription);

            const result = await subscriptionService.upgradeSubscription('user_123', {
                stripeCustomerId: 'cus_123',
                stripeSubscriptionId: 'sub_123',
            });

            expect(result).toEqual(mockUpdatedSubscription);
            expect(prisma.subscription.update).toHaveBeenCalledWith({
                where: { id: 'sub_123' },
                data: expect.objectContaining({
                    type: 'PRO',
                    stripeCustomerId: 'cus_123',
                    stripeSubscriptionId: 'sub_123',
                }),
            });
        });

        it('should create new subscription if none exists', async () => {
            prisma.subscription.findUnique.mockResolvedValue(null);

            const mockCreatedSubscription = {
                id: 'sub_456',
                userId: 'user_123',
                type: 'PRO',
                isActive: true,
            };

            prisma.subscription.create.mockResolvedValue(mockCreatedSubscription);

            const result = await subscriptionService.upgradeSubscription('user_123', {
                stripeCustomerId: 'cus_123',
            });

            expect(result).toEqual(mockCreatedSubscription);
            expect(prisma.subscription.create).toHaveBeenCalled();
        });
    });

    describe('cancelSubscription', () => {
        it('should cancel active subscription', async () => {
            const mockSubscription = {
                id: 'sub_123',
                userId: 'user_123',
                type: 'PRO',
                isActive: true,
            };

            const mockCancelledSubscription = {
                ...mockSubscription,
                isActive: false,
                endDate: new Date(),
            };

            prisma.subscription.findUnique.mockResolvedValue(mockSubscription);
            prisma.subscription.update.mockResolvedValue(mockCancelledSubscription);

            const result = await subscriptionService.cancelSubscription('user_123');

            expect(result).toEqual(mockCancelledSubscription);
            expect(prisma.subscription.update).toHaveBeenCalledWith({
                where: { id: 'sub_123' },
                data: expect.objectContaining({
                    isActive: false,
                    endDate: expect.any(Date),
                }),
            });
        });

        it('should throw error when subscription not found', async () => {
            prisma.subscription.findUnique.mockResolvedValue(null);

            await expect(subscriptionService.cancelSubscription('user_123'))
                .rejects.toThrow('Subscription not found');
        });

        it('should throw error when subscription already cancelled', async () => {
            const mockCancelledSubscription = {
                id: 'sub_123',
                userId: 'user_123',
                type: 'PRO',
                isActive: false,
            };

            prisma.subscription.findUnique.mockResolvedValue(mockCancelledSubscription);

            await expect(subscriptionService.cancelSubscription('user_123'))
                .rejects.toThrow('Subscription already cancelled');
        });
    });

    describe('getSubscriptionPlans', () => {
        it('should return all available subscription plans', async () => {
            const result = await subscriptionService.getSubscriptionPlans();

            expect(result).toEqual([
                {
                    id: 'free',
                    name: 'Free Plan',
                    type: 'FREE',
                    price: 0,
                    currency: 'TRY',
                    interval: 'month',
                    features: [
                        '2 course limit',
                        'Basic attendance tracking',
                        'Local storage',
                    ],
                },
                {
                    id: 'pro',
                    name: 'Pro Plan',
                    type: 'PRO',
                    price: 99.99,
                    currency: 'TRY',
                    interval: 'year',
                    features: [
                        'Unlimited courses',
                        'Advanced analytics',
                        'Cloud sync',
                        'Priority support',
                        'Export to PDF/Excel',
                    ],
                },
            ]);
        });
    });

    describe('validateSubscriptionAccess', () => {
        it('should return true for PRO users accessing unlimited features', async () => {
            const mockProSubscription = {
                type: 'PRO',
                isActive: true,
                endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
            };

            prisma.subscription.findUnique.mockResolvedValue(mockProSubscription);

            const result = await subscriptionService.validateSubscriptionAccess('user_123', 'unlimited_courses');

            expect(result).toBe(true);
        });

        it('should return false for FREE users accessing premium features', async () => {
            const mockFreeSubscription = {
                type: 'FREE',
                isActive: true,
            };

            prisma.subscription.findUnique.mockResolvedValue(mockFreeSubscription);

            const result = await subscriptionService.validateSubscriptionAccess('user_123', 'advanced_analytics');

            expect(result).toBe(false);
        });

        it('should return false for expired subscriptions', async () => {
            const mockExpiredSubscription = {
                type: 'PRO',
                isActive: false,
                endDate: new Date(Date.now() - 24 * 60 * 60 * 1000), // yesterday
            };

            prisma.subscription.findUnique.mockResolvedValue(mockExpiredSubscription);

            const result = await subscriptionService.validateSubscriptionAccess('user_123', 'unlimited_courses');

            expect(result).toBe(false);
        });
    });
}); 