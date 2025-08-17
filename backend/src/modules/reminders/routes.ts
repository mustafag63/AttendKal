import { Router } from 'express';
import {
    getReminders,
    getReminder,
    createReminder,
    updateReminder,
    deleteReminder
} from './controller';
import { authenticate } from '@src/middlewares/auth';
import { validate } from '@src/middlewares/validation';
import { createReminderSchema, updateReminderSchema } from '@src/lib/courseValidations';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Reminder routes
router.get('/', getReminders);
router.post('/', validate(createReminderSchema), createReminder);
router.get('/:id', getReminder);
router.put('/:id', validate(updateReminderSchema), updateReminder);
router.delete('/:id', deleteReminder);

export default router;
