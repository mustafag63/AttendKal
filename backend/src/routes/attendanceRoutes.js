import express from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/authMiddleware.js';
import { validate } from '../middleware/validationMiddleware.js';
import {
    getAttendance,
    markAttendance,
    getAttendanceStats,
    deleteAttendance,
} from '../controllers/attendanceController.js';

const router = express.Router();

// All attendance routes require authentication
router.use(authenticate);

// Validation rules
const markAttendanceValidation = [
    body('courseId')
        .notEmpty()
        .withMessage('Course ID is required'),
    body('status')
        .isIn(['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'])
        .withMessage('Status must be one of: PRESENT, ABSENT, LATE, EXCUSED'),
    body('date')
        .isISO8601()
        .withMessage('Date must be in ISO 8601 format'),
    body('note')
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage('Note must not exceed 500 characters'),
];

// Routes
router.get('/', getAttendance);
router.post('/', markAttendanceValidation, validate, markAttendance);
router.get('/stats', getAttendanceStats);
router.delete('/:id', deleteAttendance);

export default router; 