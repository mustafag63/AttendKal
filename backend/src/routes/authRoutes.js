import express from 'express';
import { body } from 'express-validator';
import { validate, sanitizeInput, customValidators } from '../middleware/validationMiddleware.js';
import { authenticate } from '../middleware/authMiddleware.js';
import {
  register,
  login,
  logout,
  refreshToken,
  getMe,
  updatePassword,
  updateProfile,
} from '../controllers/authController.js';

const router = express.Router();

// Validation rules
const registerValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters'),
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .custom(customValidators.isStrongPassword)
    .withMessage('Password does not meet security requirements'),
  body('confirmPassword')
    .custom((value, { req }) => {
      if (value !== req.body.password) {
        throw new Error('Passwords do not match');
      }
      return true;
    }),
];

const loginValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
];

const updatePasswordValidation = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .custom(customValidators.isStrongPassword)
    .withMessage('New password does not meet security requirements'),
  body('confirmNewPassword')
    .custom((value, { req }) => {
      if (value !== req.body.newPassword) {
        throw new Error('New passwords do not match');
      }
      return true;
    }),
];

const updateProfileValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Name must be between 2 and 50 characters'),
  body('avatar')
    .optional()
    .isURL()
    .withMessage('Avatar must be a valid URL'),
];

// Auth routes
router.post('/register', sanitizeInput, registerValidation, validate, register);
router.post('/login', sanitizeInput, loginValidation, validate, login);
router.post('/refresh-token', sanitizeInput, refreshToken);

// Protected routes
router.use(authenticate); // All routes after this middleware are protected

router.post('/logout', sanitizeInput, logout);
router.get('/me', getMe);
router.patch('/update-password', sanitizeInput, updatePasswordValidation, validate, updatePassword);
router.patch('/update-profile', sanitizeInput, updateProfileValidation, validate, updateProfile);

export default router; 