import express from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/authMiddleware.js';
import { validate } from '../middleware/validationMiddleware.js';
import {
    getCourses,
    getCourse,
    createCourse,
    updateCourse,
    deleteCourse,
    getCourseStats,
} from '../controllers/courseController.js';

const router = express.Router();

// All course routes require authentication
router.use(authenticate);

// Validation rules
const createCourseValidation = [
    body('name')
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Course name must be between 2 and 100 characters'),
    body('code')
        .trim()
        .isLength({ min: 2, max: 20 })
        .withMessage('Course code must be between 2 and 20 characters'),
    body('instructor')
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Instructor name must be between 2 and 100 characters'),
    body('description')
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage('Description must not exceed 500 characters'),
    body('color')
        .optional()
        .matches(/^#[0-9A-F]{6}$/i)
        .withMessage('Color must be a valid hex color'),
    body('schedule')
        .optional()
        .isArray()
        .withMessage('Schedule must be an array'),
    body('schedule.*.dayOfWeek')
        .optional()
        .isInt({ min: 0, max: 6 })
        .withMessage('Day of week must be between 0 and 6'),
    body('schedule.*.startTime')
        .optional()
        .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
        .withMessage('Start time must be in HH:MM format'),
    body('schedule.*.endTime')
        .optional()
        .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
        .withMessage('End time must be in HH:MM format'),
    body('schedule.*.room')
        .optional()
        .trim()
        .isLength({ max: 50 })
        .withMessage('Room must not exceed 50 characters'),
];

const updateCourseValidation = [
    body('name')
        .optional()
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Course name must be between 2 and 100 characters'),
    body('code')
        .optional()
        .trim()
        .isLength({ min: 2, max: 20 })
        .withMessage('Course code must be between 2 and 20 characters'),
    body('instructor')
        .optional()
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Instructor name must be between 2 and 100 characters'),
    body('description')
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage('Description must not exceed 500 characters'),
    body('color')
        .optional()
        .matches(/^#[0-9A-F]{6}$/i)
        .withMessage('Color must be a valid hex color'),
    body('schedule')
        .optional()
        .isArray()
        .withMessage('Schedule must be an array'),
];

// Routes
router.get('/', getCourses);
router.post('/', createCourseValidation, validate, createCourse);
router.get('/stats', getCourseStats);
router.get('/:id', getCourse);
router.put('/:id', updateCourseValidation, validate, updateCourse);
router.delete('/:id', deleteCourse);

export default router; 