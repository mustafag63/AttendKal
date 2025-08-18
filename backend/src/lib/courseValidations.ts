import { z } from 'zod';

/* ---------- Helpers ---------- */

const isoDateTime = z
    .string()
    .datetime('Invalid datetime format'); // RFC 3339 (Zod'un yerleşik kontrolü)

const uuid = z.string().uuid('Invalid UUID');

const hhmm = z
    .string()
    .regex(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)');

/* ---------- Course ---------- */

export const createCourseSchema = z.object({
    name: z.string().min(1, 'Course name is required').max(100, 'Course name too long'),
    code: z.string().max(20, 'Course code too long').optional(),
    teacher: z.string().max(100, 'Teacher name too long').optional(),
    location: z.string().max(100, 'Location too long').optional(),
    color: z.string().regex(/^#[0-9A-F]{6}$/i, 'Invalid color format').optional(),
    note: z.string().max(500, 'Note too long').optional(),
    maxAbsences: z.number().int().min(0, 'Max absences must be non-negative').max(50, 'Max absences too high'),
});

export const updateCourseSchema = createCourseSchema.partial();

/* ---------- Meeting (FIX: startTime / endTime) ---------- */
/* Prisma şemana uyum: startHHmm + durationMin yerine startTime + endTime ('HH:mm') */

export const createMeetingSchema = z.object({
    weekday: z.number().int().min(1, 'Weekday must be 1-7').max(7, 'Weekday must be 1-7'),
    startTime: hhmm, // e.g. "09:30"
    endTime: hhmm,   // e.g. "11:00"
    location: z.string().max(100, 'Location too long').optional(),
    note: z.string().max(500, 'Note too long').optional(),
});

export const updateMeetingSchema = createMeetingSchema.partial();

/* ---------- Session ---------- */
/* Controller input: startUtc + durationMin → controller içinde startTime/endTime hesaplanıyor */

export const createSessionSchema = z.object({
    startUtc: isoDateTime,
    durationMin: z.number().int().min(15, 'Minimum duration is 15 minutes').max(480, 'Maximum 8 hours').default(90),
    source: z.enum(['AUTO', 'MANUAL']).default('MANUAL'),
});

export const generateSessionsSchema = z.object({
    courseId: uuid,
    from: isoDateTime,
    to: isoDateTime,
});

export const getSessionsSchema = z.object({
    from: isoDateTime.optional(),
    to: isoDateTime.optional(),
    courseId: uuid.optional(),
});

/* ---------- Attendance ---------- */

export const markAttendanceSchema = z.object({
    status: z.enum(['PRESENT', 'ABSENT', 'EXCUSED']),
    note: z.string().max(500, 'Note too long').optional(),
});

/* ---------- Reminder ---------- */

export const createReminderSchema = z.object({
    courseId: uuid.optional(),
    title: z.string().min(1, 'Title is required').max(200, 'Title too long'),
    morningOfClass: z.boolean().default(true),
    minutesBefore: z.number().int().min(0, 'Minutes before must be non-negative').max(1440, 'Maximum 24 hours before').default(60),
    thresholdAlerts: z.boolean().default(true),
    cron: z.string().max(100, 'Cron expression too long').optional(),
    enabled: z.boolean().default(true),
});

export const updateReminderSchema = createReminderSchema.partial();

/* ---------- Types ---------- */

export type CreateCourseInput = z.infer<typeof createCourseSchema>;
export type UpdateCourseInput = z.infer<typeof updateCourseSchema>;
export type CreateMeetingInput = z.infer<typeof createMeetingSchema>;
export type UpdateMeetingInput = z.infer<typeof updateMeetingSchema>;
export type CreateSessionInput = z.infer<typeof createSessionSchema>;
export type GenerateSessionsInput = z.infer<typeof generateSessionsSchema>;
export type GetSessionsInput = z.infer<typeof getSessionsSchema>;
export type MarkAttendanceInput = z.infer<typeof markAttendanceSchema>;
export type CreateReminderInput = z.infer<typeof createReminderSchema>;
export type UpdateReminderInput = z.infer<typeof updateReminderSchema>;
