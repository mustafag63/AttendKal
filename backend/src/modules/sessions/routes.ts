import { Router } from 'express';
import { getSessions, createSession, generateSessions } from './controller';
import { authenticate } from '@src/middlewares/auth';
import { validate, validateQuery } from '@src/middlewares/validation';
import {
    createSessionSchema,
    generateSessionsSchema,
    getSessionsSchema
} from '@src/lib/courseValidations';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Session routes
router.get('/', validateQuery(getSessionsSchema), getSessions);
router.post('/generate', validate(generateSessionsSchema), generateSessions);
router.post('/:courseId', validate(createSessionSchema), createSession);

export default router;
