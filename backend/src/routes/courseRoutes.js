import express from 'express';
import { authenticate, checkOwnership } from '../middleware/authMiddleware.js';

const router = express.Router();

// Placeholder endpoints - will be implemented with controllers
router.use(authenticate); // All course routes require authentication

router.get('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'Get all courses endpoint - to be implemented',
        data: [],
    });
});

router.post('/', (req, res) => {
    res.json({
        status: 'success',
        message: 'Create course endpoint - to be implemented',
    });
});

router.get('/:id', checkOwnership(), (req, res) => {
    res.json({
        status: 'success',
        message: 'Get course by ID endpoint - to be implemented',
    });
});

router.put('/:id', checkOwnership(), (req, res) => {
    res.json({
        status: 'success',
        message: 'Update course endpoint - to be implemented',
    });
});

router.delete('/:id', checkOwnership(), (req, res) => {
    res.json({
        status: 'success',
        message: 'Delete course endpoint - to be implemented',
    });
});

export default router; 