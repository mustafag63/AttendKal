import express from 'express';
import { authenticate, restrictTo } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(authenticate); // All user routes require authentication

// Admin only routes
router.get('/', restrictTo('ADMIN'), (req, res) => {
    res.json({
        status: 'success',
        message: 'Get all users endpoint (Admin only) - to be implemented',
        data: [],
    });
});

router.get('/:id', restrictTo('ADMIN'), (req, res) => {
    res.json({
        status: 'success',
        message: 'Get user by ID endpoint (Admin only) - to be implemented',
        data: {},
    });
});

router.patch('/:id/activate', restrictTo('ADMIN'), (req, res) => {
    res.json({
        status: 'success',
        message: 'Activate user endpoint (Admin only) - to be implemented',
    });
});

router.patch('/:id/deactivate', restrictTo('ADMIN'), (req, res) => {
    res.json({
        status: 'success',
        message: 'Deactivate user endpoint (Admin only) - to be implemented',
    });
});

export default router; 