import { body, param, query } from 'express-validator';

// Common validation rules
const emailValidation = body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address')
    .isLength({ max: 255 })
    .withMessage('Email must not exceed 255 characters');

const passwordValidation = body('password')
    .isLength({ min: 8, max: 128 })
    .withMessage('Password must be between 8 and 128 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character');

const nameValidation = body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters')
    .matches(/^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$/)
    .withMessage('Name can only contain letters and spaces');

const idValidation = param('id')
    .isLength({ min: 1, max: 50 })
    .withMessage('Invalid ID format')
    .matches(/^[a-zA-Z0-9_-]+$/)
    .withMessage('ID contains invalid characters');

// Auth validation schemas
export const registerValidation = [
    nameValidation,
    emailValidation,
    passwordValidation,
    body('confirmPassword')
        .custom((value, { req }) => {
            if (value !== req.body.password) {
                throw new Error('Password confirmation does not match password');
            }
            return true;
        }),
];

export const loginValidation = [
    body('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email address'),
    body('password')
        .notEmpty()
        .withMessage('Password is required'),
];

export const forgotPasswordValidation = [
    emailValidation,
];

export const resetPasswordValidation = [
    body('token')
        .notEmpty()
        .withMessage('Reset token is required')
        .isLength({ min: 10, max: 255 })
        .withMessage('Invalid reset token format'),
    passwordValidation,
    body('confirmPassword')
        .custom((value, { req }) => {
            if (value !== req.body.password) {
                throw new Error('Password confirmation does not match password');
            }
            return true;
        }),
];

// Course validation schemas
export const createCourseValidation = [
    body('name')
        .trim()
        .isLength({ min: 2, max: 200 })
        .withMessage('Course name must be between 2 and 200 characters')
        .matches(/^[a-zA-ZğüşıöçĞÜŞİÖÇ0-9\s\-\.]+$/)
        .withMessage('Course name contains invalid characters'),

    body('code')
        .trim()
        .isLength({ min: 2, max: 20 })
        .withMessage('Course code must be between 2 and 20 characters')
        .matches(/^[A-Z0-9\-]+$/)
        .withMessage('Course code can only contain uppercase letters, numbers, and hyphens'),

    body('instructor')
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Instructor name must be between 2 and 100 characters')
        .matches(/^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\.]+$/)
        .withMessage('Instructor name contains invalid characters'),

    body('description')
        .optional()
        .trim()
        .isLength({ max: 1000 })
        .withMessage('Description must not exceed 1000 characters'),

    body('color')
        .matches(/^#[0-9A-Fa-f]{6}$/)
        .withMessage('Color must be a valid hex color code'),

    body('credits')
        .optional()
        .isInt({ min: 1, max: 10 })
        .withMessage('Credits must be between 1 and 10'),

    body('semester')
        .optional()
        .trim()
        .isLength({ max: 50 })
        .withMessage('Semester must not exceed 50 characters'),

    body('year')
        .optional()
        .isInt({ min: 2020, max: 2030 })
        .withMessage('Year must be between 2020 and 2030'),

    body('schedule')
        .optional()
        .isArray()
        .withMessage('Schedule must be an array'),

    body('schedule.*.dayOfWeek')
        .if(body('schedule').exists())
        .isInt({ min: 0, max: 6 })
        .withMessage('Day of week must be between 0 (Sunday) and 6 (Saturday)'),

    body('schedule.*.startTime')
        .if(body('schedule').exists())
        .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
        .withMessage('Start time must be in HH:MM format'),

    body('schedule.*.endTime')
        .if(body('schedule').exists())
        .matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
        .withMessage('End time must be in HH:MM format'),

    body('schedule.*.room')
        .optional()
        .trim()
        .isLength({ max: 50 })
        .withMessage('Room must not exceed 50 characters'),
];

export const updateCourseValidation = [
    idValidation,
    ...createCourseValidation.map(rule => rule.optional()),
];

export const getCourseValidation = [idValidation];

export const deleteCourseValidation = [idValidation];

// Attendance validation schemas
export const markAttendanceValidation = [
    body('courseId')
        .notEmpty()
        .withMessage('Course ID is required')
        .isLength({ min: 1, max: 50 })
        .withMessage('Invalid course ID format'),

    body('date')
        .isISO8601()
        .withMessage('Date must be in valid ISO format')
        .custom((value) => {
            const date = new Date(value);
            const now = new Date();
            const maxPast = new Date();
            maxPast.setDate(now.getDate() - 30); // Allow marking attendance up to 30 days in the past

            if (date > now) {
                throw new Error('Cannot mark attendance for future dates');
            }
            if (date < maxPast) {
                throw new Error('Cannot mark attendance for dates older than 30 days');
            }
            return true;
        }),

    body('status')
        .isIn(['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'])
        .withMessage('Status must be one of: PRESENT, ABSENT, LATE, EXCUSED'),

    body('note')
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage('Note must not exceed 500 characters'),

    body('latitude')
        .optional()
        .isFloat({ min: -90, max: 90 })
        .withMessage('Latitude must be between -90 and 90'),

    body('longitude')
        .optional()
        .isFloat({ min: -180, max: 180 })
        .withMessage('Longitude must be between -180 and 180'),
];

export const getAttendanceValidation = [
    query('courseId')
        .optional()
        .isLength({ min: 1, max: 50 })
        .withMessage('Invalid course ID format'),

    query('date')
        .optional()
        .isISO8601()
        .withMessage('Date must be in valid ISO format'),

    query('startDate')
        .optional()
        .isISO8601()
        .withMessage('Start date must be in valid ISO format'),

    query('endDate')
        .optional()
        .isISO8601()
        .withMessage('End date must be in valid ISO format')
        .custom((value, { req }) => {
            if (req.query.startDate && value) {
                const start = new Date(req.query.startDate);
                const end = new Date(value);
                if (end <= start) {
                    throw new Error('End date must be after start date');
                }
            }
            return true;
        }),
];

// Subscription validation schemas
export const updateSubscriptionValidation = [
    body('planType')
        .isIn(['FREE', 'PRO', 'PREMIUM'])
        .withMessage('Plan type must be one of: FREE, PRO, PREMIUM'),
];

// User validation schemas
export const updateProfileValidation = [
    body('name')
        .optional()
        .trim()
        .isLength({ min: 2, max: 100 })
        .withMessage('Name must be between 2 and 100 characters')
        .matches(/^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$/)
        .withMessage('Name can only contain letters and spaces'),

    body('avatar')
        .optional()
        .isURL()
        .withMessage('Avatar must be a valid URL'),
];

export const changePasswordValidation = [
    body('currentPassword')
        .notEmpty()
        .withMessage('Current password is required'),

    passwordValidation.withMessage('New password must meet security requirements'),

    body('confirmPassword')
        .custom((value, { req }) => {
            if (value !== req.body.password) {
                throw new Error('Password confirmation does not match new password');
            }
            return true;
        }),
];

// Pagination validation
export const paginationValidation = [
    query('page')
        .optional()
        .isInt({ min: 1 })
        .withMessage('Page must be a positive integer'),

    query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit must be between 1 and 100'),

    query('sort')
        .optional()
        .isIn(['createdAt', 'updatedAt', 'name', 'email'])
        .withMessage('Sort field must be one of: createdAt, updatedAt, name, email'),

    query('order')
        .optional()
        .isIn(['asc', 'desc'])
        .withMessage('Order must be either asc or desc'),
]; 