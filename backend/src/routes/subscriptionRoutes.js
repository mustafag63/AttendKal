import express from 'express';
import { authenticate } from '../middleware/authMiddleware.js';
import { changeSubscriptionPlanValidation } from '../dto/validationSchemas.js';
import { validateRequest } from '../middleware/validationMiddleware.js';
import {
  getSubscription,
  getSubscriptionPlans,
  changeSubscriptionPlan,
  upgradeSubscription,
  cancelSubscription,
} from '../controllers/subscriptionController.js';

const router = express.Router();

// Maintenance middleware can be added here if needed
// router.use(featureMaintenanceMode('subscription'));

// Get available subscription plans (public route - no auth required)
router.get('/plans', getSubscriptionPlans);

// All other subscription routes require authentication
router.use(authenticate);

// Get current subscription
router.get('/', getSubscription);

// Change subscription plan (free during beta)
router.post('/change-plan', changeSubscriptionPlanValidation, validateRequest, changeSubscriptionPlan);

// Legacy upgrade subscription endpoint (for backward compatibility)
router.post('/upgrade', changeSubscriptionPlanValidation, validateRequest, upgradeSubscription);

// Cancel subscription
router.post('/cancel', cancelSubscription);

export default router; 