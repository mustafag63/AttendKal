/**
 * Database Enum Constants
 * These should match the enums defined in Prisma schema
 */

export const UserRole = {
    STUDENT: 'STUDENT',
    TEACHER: 'TEACHER',
    ADMIN: 'ADMIN'
};

export const AttendanceStatus = {
    PRESENT: 'PRESENT',
    ABSENT: 'ABSENT',
    LATE: 'LATE',
    EXCUSED: 'EXCUSED'
};

export const SubscriptionType = {
    FREE: 'FREE',
    PRO: 'PRO',
    PREMIUM: 'PREMIUM'
};

export const NotificationType = {
    INFO: 'INFO',
    WARNING: 'WARNING',
    ERROR: 'ERROR',
    SUCCESS: 'SUCCESS'
};

// API Response Status Constants
export const ResponseStatus = {
    SUCCESS: 'success',
    ERROR: 'error',
    FAIL: 'fail'
};

// HTTP Status Codes
export const HttpStatus = {
    OK: 200,
    CREATED: 201,
    NO_CONTENT: 204,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    CONFLICT: 409,
    UNPROCESSABLE_ENTITY: 422,
    TOO_MANY_REQUESTS: 429,
    INTERNAL_SERVER_ERROR: 500,
    SERVICE_UNAVAILABLE: 503
};

// Validation Constants
export const ValidationLimits = {
    USER_NAME_MIN: 2,
    USER_NAME_MAX: 100,
    EMAIL_MAX: 255,
    PASSWORD_MIN: 8,
    PASSWORD_MAX: 128,
    COURSE_NAME_MIN: 2,
    COURSE_NAME_MAX: 100,
    COURSE_CODE_MIN: 2,
    COURSE_CODE_MAX: 20,
    COURSE_DESCRIPTION_MAX: 1000,
    ATTENDANCE_NOTE_MAX: 255
};

// Subscription Limits
export const SubscriptionLimits = {
    FREE_COURSES: 2,
    PRO_COURSES: 50,
    PREMIUM_COURSES: -1 // unlimited
};

export default {
    UserRole,
    AttendanceStatus,
    SubscriptionType,
    NotificationType,
    ResponseStatus,
    HttpStatus,
    ValidationLimits,
    SubscriptionLimits
}; 