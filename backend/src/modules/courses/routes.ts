import { Router } from 'express';
import {
    getCourses,
    getCourse,
    createCourse,
    updateCourse,
    deleteCourse,
    createMeeting,
    deleteMeeting
} from './controller';
import { authenticate } from '@src/middlewares/auth';
import { validate } from '@src/middlewares/validation';
import {
    createCourseSchema,
    updateCourseSchema,
    createMeetingSchema
} from '@src/lib/courseValidations';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Course routes
router.get('/', getCourses);
router.post('/', validate(createCourseSchema), createCourse);
router.get('/:id', getCourse);
router.put('/:id', validate(updateCourseSchema), updateCourse);
router.delete('/:id', deleteCourse);

// Meeting routes
router.post('/:id/meetings', validate(createMeetingSchema), createMeeting);
router.delete('/:id/meetings/:mid', deleteMeeting);

export default router;
