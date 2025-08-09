import { catchAsync } from '../middleware/errorHandler.js';
import { subscriptionService } from '../routes/services/subscriptionService.js';
import { AppError } from '../middleware/errorHandler.js';

// Get user subscription
export const getSubscription = catchAsync(async (req, res, next) => {
  try {
    const subscription = await subscriptionService.getSubscription(req.user.id);
    res.status(200).json({
      status: 'success',
      data: subscription,
    });
  } catch (error) {
    // If user doesn't have a subscription, create a FREE one
    if (error.statusCode === 404) {
      const newSubscription = await subscriptionService.createSubscription({
        userId: req.user.id,
        plan: 'FREE',
      });
      res.status(200).json({
        status: 'success',
        data: newSubscription,
      });
    } else {
      next(error);
    }
  }
});

// Get available subscription plans
export const getSubscriptionPlans = catchAsync(async (req, res) => {
  const plans = await subscriptionService.getSubscriptionPlans();
  res.status(200).json({
    status: 'success',
    data: plans,
  });
});

// Change subscription plan (free during beta)
export const changeSubscriptionPlan = catchAsync(async (req, res, next) => {
  const { plan } = req.body;

  if (!plan) {
    return next(new AppError('Plan is required', 400));
  }

  const updatedSubscription = await subscriptionService.changeSubscriptionPlan(req.user.id, { plan });
  
  res.status(200).json({
    status: 'success',
    message: `Successfully switched to ${plan} plan`,
    data: updatedSubscription,
  });
});

// Legacy upgrade subscription endpoint (for backward compatibility)
export const upgradeSubscription = catchAsync(async (req, res, next) => {
  return changeSubscriptionPlan(req, res, next);
});

// Cancel subscription
export const cancelSubscription = catchAsync(async (req, res) => {
  const cancelledSubscription = await subscriptionService.cancelSubscription(req.user.id);
  
  res.status(200).json({
    status: 'success',
    message: 'Subscription cancelled successfully',
    data: cancelledSubscription,
  });
}); 