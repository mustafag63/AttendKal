import { z } from 'zod';

// User schemas
export const UserSchema = z.object({
    id: z.string().optional(),
    name: z.string().min(1, 'Name is required'),
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters').optional(),
    role: z.enum(['admin', 'user']),
    createdAt: z.string().optional(),
    updatedAt: z.string().optional(),
});

export const CreateUserSchema = UserSchema.omit({ id: true, createdAt: true, updatedAt: true });
export const UpdateUserSchema = UserSchema.partial().omit({ createdAt: true, updatedAt: true });

// Course schemas
export const CourseSchema = z.object({
    id: z.string().optional(),
    code: z.string().min(1, 'Course code is required'),
    name: z.string().min(1, 'Course name is required'),
    day: z.enum(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
    start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)'),
    end: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)'),
    createdAt: z.string().optional(),
    updatedAt: z.string().optional(),
});

export const CreateCourseSchema = CourseSchema.omit({ id: true, createdAt: true, updatedAt: true });
export const UpdateCourseSchema = CourseSchema.partial().omit({ createdAt: true, updatedAt: true });

// Attendance schemas
export const AttendanceSchema = z.object({
    id: z.string().optional(),
    courseId: z.string().min(1, 'Course is required'),
    userId: z.string().min(1, 'User is required'),
    date: z.string().min(1, 'Date is required'),
    status: z.enum(['present', 'absent', 'late']),
    createdAt: z.string().optional(),
    updatedAt: z.string().optional(),
});

export const CreateAttendanceSchema = AttendanceSchema.omit({ id: true, createdAt: true, updatedAt: true });
export const UpdateAttendanceSchema = AttendanceSchema.partial().omit({ createdAt: true, updatedAt: true });

// Auth schemas
export const LoginSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
});

// API response schemas
export const AuthResponseSchema = z.object({
    accessToken: z.string(),
    refreshToken: z.string().optional(),
});

export const UserMeSchema = z.object({
    id: z.string(),
    email: z.string(),
    role: z.enum(['admin', 'user']),
    name: z.string(),
});

// Types
export type User = z.infer<typeof UserSchema>;
export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;

export type Course = z.infer<typeof CourseSchema>;
export type CreateCourse = z.infer<typeof CreateCourseSchema>;
export type UpdateCourse = z.infer<typeof UpdateCourseSchema>;

export type Attendance = z.infer<typeof AttendanceSchema>;
export type CreateAttendance = z.infer<typeof CreateAttendanceSchema>;
export type UpdateAttendance = z.infer<typeof UpdateAttendanceSchema>;

export type LoginCredentials = z.infer<typeof LoginSchema>;
export type AuthResponse = z.infer<typeof AuthResponseSchema>;
export type UserMe = z.infer<typeof UserMeSchema>; 