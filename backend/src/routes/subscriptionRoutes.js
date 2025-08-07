import express from 'express';
import { authenticate } from '../middleware/authMiddleware.js';
import { subscriptionMaintenanceMiddleware } from '../middleware/maintenanceMiddleware.js';
import {
    getSubscription,
    upgradeSubscription,
    cancelSubscription,
} from '../controllers/subscriptionController.js';

const router = express.Router();

// Apply maintenance middleware first
router.use(subscriptionMaintenanceMiddleware);

// All subscription routes require authentication
router.use(authenticate);

// Get current subscription
router.get('/', getSubscription);

// Upgrade subscription
router.post('/upgrade', upgradeSubscription);

// Cancel subscription
router.post('/cancel', cancelSubscription);

export default router; 