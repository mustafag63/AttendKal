import { Router } from 'express';
import { markAttendance, getAttendance, logNotificationAction } from './controller';
import { authenticate } from '@src/middlewares/auth';
import { validate } from '@src/middlewares/validation';
import { markAttendanceSchema } from '@src/lib/courseValidations';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Attendance routes
router.get('/:sessionId', getAttendance);
router.post('/:sessionId', validate(markAttendanceSchema), markAttendance);

// Notification action logging
router.post('/notification-action', logNotificationAction);

export default router;
