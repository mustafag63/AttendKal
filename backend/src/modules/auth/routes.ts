import { Router } from 'express';
import { register, login, getProfile, changePassword } from './controller';
import { authenticate } from '@src/middlewares/auth';
import { validate } from '@src/middlewares/validation';
import { authLimiter } from '@src/middlewares/rateLimiter';
import { registerSchema, loginSchema, changePasswordSchema } from '@src/lib/validations';

const router = Router();

// Public routes (with rate limiting)
router.post('/register', authLimiter, validate(registerSchema), register);
router.post('/login', authLimiter, validate(loginSchema), login);

// Protected routes
router.get('/me', authenticate, getProfile);
router.post('/change-password', authenticate, validate(changePasswordSchema), changePassword);

export default router;
