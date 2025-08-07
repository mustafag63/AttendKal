import { catchAsync } from '../middleware/errorHandler.js';

// Get user subscription - simplified for now
export const getSubscription = catchAsync(async (req, res, next) => {
    // Return default free subscription
    res.status(200).json({
        status: 'success',
        data: {
            id: 'default-subscription',
            type: 'FREE',
            isActive: true,
            startDate: new Date().toISOString(),
            endDate: null,
            stripeCustomerId: null,
            stripeSubscriptionId: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        },
    });
});

// Upgrade subscription - placeholder
export const upgradeSubscription = catchAsync(async (req, res, next) => {
    res.status(200).json({
        status: 'success',
        message: 'Subscription upgrade feature is coming soon!',
        data: {
            type: 'FREE',
            isActive: true,
        },
    });
});

// Cancel subscription - placeholder  
export const cancelSubscription = catchAsync(async (req, res, next) => {
    res.status(200).json({
        status: 'success',
        message: 'Subscription cancellation feature is coming soon!',
    });
}); 