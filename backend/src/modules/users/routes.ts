import { Router } from 'express';
import { authenticate } from '../../middlewares/auth';
import {
    storeFCMToken,
    removeFCMToken,
    getUserFCMTokens,
    cleanupInactiveTokens
} from './controller';

const router = Router();

// FCM Token Management Routes
router.post('/:userId/fcm-token', authenticate, storeFCMToken);
router.delete('/:userId/fcm-token', authenticate, removeFCMToken);
router.get('/:userId/fcm-tokens', authenticate, getUserFCMTokens);

// Admin/maintenance routes
router.post('/fcm-tokens/cleanup', authenticate, cleanupInactiveTokens);

export default router;
