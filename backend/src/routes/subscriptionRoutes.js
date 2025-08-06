import express from 'express';
import { authenticate } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(authenticate); // All subscription routes require authentication

router.get('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'Get subscription status endpoint - to be implemented',
        data: {},
    });
});

router.post('/upgrade', (req, res) => {
    res.json({
        status: 'success',
        message: 'Upgrade subscription endpoint - to be implemented',
    });
});

router.post('/cancel', (req, res) => {
    res.json({
        status: 'success',
        message: 'Cancel subscription endpoint - to be implemented',
    });
});

export default router; 