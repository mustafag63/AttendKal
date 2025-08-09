import { prisma } from '../../utils/prisma.js';
import { AppError } from '../../middleware/errorHandler.js';

export class SubscriptionService {
  // Get user's subscription
  async getSubscription(userId) {
    if (!userId) {
      throw new AppError('User ID is required', 400);
    }

    const subscription = await prisma.subscription.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    if (!subscription) {
      throw new AppError('Subscription not found', 404);
    }

    return subscription;
  }

  // Create new subscription
  async createSubscription(subscriptionData) {
    const { userId, plan, status = 'ACTIVE' } = subscriptionData;

    if (!userId || !plan) {
      throw new AppError('User ID and plan are required', 400);
    }

    // Check if user already has a subscription
    const existingSubscription = await prisma.subscription.findUnique({
      where: { userId },
    });

    if (existingSubscription) {
      throw new AppError('User already has a subscription', 400);
    }

    const subscription = await prisma.subscription.create({
      data: {
        userId,
        plan,
        status,
        startDate: new Date(),
        endDate: this.calculateEndDate(plan),
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    return subscription;
  }

  // Change subscription plan (free switching for now, payment will be added later)
  async changeSubscriptionPlan(userId, planData) {
    const { plan } = planData;

    if (!plan) {
      throw new AppError('New plan is required', 400);
    }

    // Validate plan type
    const validPlans = ['FREE', 'PREMIUM'];
    if (!validPlans.includes(plan)) {
      throw new AppError('Invalid plan type. Must be one of: FREE, PREMIUM', 400);
    }

    const subscription = await this.getSubscription(userId);

    // For now, allow free switching between all plans (no payment required)
    const updatedSubscription = await prisma.subscription.update({
      where: { userId },
      data: {
        plan,
        endDate: this.calculateEndDate(plan),
        updatedAt: new Date(),
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    return updatedSubscription;
  }

  // Legacy method name for backward compatibility
  async upgradeSubscription(userId, upgradeData) {
    return this.changeSubscriptionPlan(userId, upgradeData);
  }

  // Cancel subscription
  async cancelSubscription(userId) {
    const subscription = await this.getSubscription(userId);

    if (subscription.status === 'CANCELLED') {
      throw new AppError('Subscription is already cancelled', 400);
    }

    const cancelledSubscription = await prisma.subscription.update({
      where: { userId },
      data: {
        status: 'CANCELLED',
        endDate: new Date(),
        updatedAt: new Date(),
      },
    });

    return cancelledSubscription;
  }

  // Get available subscription plans
  async getSubscriptionPlans() {
    const plans = [
      {
        id: 'FREE',
        name: 'Free',
        price: 0,
        priceNote: 'Always free',
        features: [
          'Up to 2 courses',
          'Basic attendance tracking',
          'Email support',
        ],
        courseLimit: 2,
        attendanceLimit: null,
        isRecommended: false,
      },
      {
        id: 'PREMIUM',
        name: 'Premium',
        price: 19.99,
        priceNote: 'Free during beta (payment coming soon)',
        features: [
          'Unlimited courses',
          'Advanced analytics',
          'Priority support',
          'Export reports',
          'Custom integrations',
        ],
        courseLimit: null,
        attendanceLimit: null,
        isRecommended: true,
      },
    ];

    return plans;
  }

  // Validate subscription access to features
  async validateSubscriptionAccess(userId, feature) {
    const subscription = await this.getSubscription(userId);

    if (subscription.status !== 'ACTIVE') {
      return false;
    }

    const planFeatures = this.getPlanFeatures(subscription.plan);
    return planFeatures.includes(feature);
  }

  // Helper method to calculate end date based on plan
  calculateEndDate(plan) {
    const now = new Date();
    const endDate = new Date(now);
        
    // For now, all plans are free and don't expire (payment system will be added later)
    // Set a long expiry date for all plans
    endDate.setFullYear(endDate.getFullYear() + 10);

    return endDate;
  }

  // Helper method to get plan level for comparison
  getPlanLevel(plan) {
    const levels = {
      FREE: 1,
      PREMIUM: 2,
    };
    return levels[plan] || 0;
  }

  // Helper method to get plan features
  getPlanFeatures(plan) {
    const features = {
      FREE: ['basic_attendance', 'email_support'],
      PREMIUM: ['basic_attendance', 'advanced_analytics', 'priority_support', 'export_reports', 'unlimited_courses', 'custom_integrations'],
    };
    return features[plan] || [];
  }
}

// Create and export instance
export const subscriptionService = new SubscriptionService(); 