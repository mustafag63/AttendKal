import { prisma } from '../../utils/prisma.js';
import { AppError } from '../../middleware/errorHandler.js';
import { config } from '../../config/index.js';

export class CourseService {
  // Get user courses with pagination
  static async getUserCourses(userId, options = {}) {
    const { page = 1, limit = 10, search, isActive } = options;
    const skip = (page - 1) * limit;

    const where = {
      userId,
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { code: { contains: search, mode: 'insensitive' } },
          { instructor: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(isActive !== undefined && { isActive }),
    };

    const [courses, total] = await Promise.all([
      prisma.course.findMany({
        where,
        include: {
          schedule: true,
          _count: {
            select: {
              attendances: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.course.count({ where }),
    ]);

    return {
      courses,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasNext: page * limit < total,
        hasPrev: page > 1,
      },
    };
  }

  // Create new course
  static async createCourse(userId, courseData) {
    const { name, code, description, instructor, color, schedule } = courseData;

    // Check subscription limits
    await this._checkSubscriptionLimits(userId);

    // Check if course code already exists for user
    const existingCourse = await prisma.course.findFirst({
      where: {
        userId,
        code: code.toUpperCase(),
        isActive: true,
      },
    });

    if (existingCourse) {
      throw new AppError('Course with this code already exists', 400);
    }

    // Validate schedule data
    this._validateSchedule(schedule);

    // Create course with schedule in transaction
    const course = await prisma.$transaction(async (tx) => {
      const newCourse = await tx.course.create({
        data: {
          userId,
          name: name.trim(),
          code: code.toUpperCase().trim(),
          description: description?.trim(),
          instructor: instructor.trim(),
          color: color || '#2196F3',
        },
      });

      // Create schedule entries
      if (schedule && schedule.length > 0) {
        await tx.courseSchedule.createMany({
          data: schedule.map(s => ({
            courseId: newCourse.id,
            dayOfWeek: s.dayOfWeek,
            startTime: s.startTime,
            endTime: s.endTime,
            room: s.room?.trim(),
          })),
        });
      }

      return newCourse;
    });

    // Return course with schedule
    return this.getCourseById(userId, course.id);
  }

  // Get course by ID
  static async getCourseById(userId, courseId) {
    const course = await prisma.course.findFirst({
      where: {
        id: courseId,
        userId,
      },
      include: {
        schedule: {
          orderBy: { dayOfWeek: 'asc' },
        },
        _count: {
          select: {
            attendances: true,
          },
        },
      },
    });

    if (!course) {
      throw new AppError('Course not found', 404);
    }

    return course;
  }

  // Update course
  static async updateCourse(userId, courseId, updateData) {
    const { name, code, description, instructor, color, schedule } = updateData;

    // Check if course exists and belongs to user
    const existingCourse = await this.getCourseById(userId, courseId);

    // Check code uniqueness if code is being updated
    if (code && code.toUpperCase() !== existingCourse.code) {
      const codeExists = await prisma.course.findFirst({
        where: {
          userId,
          code: code.toUpperCase(),
          isActive: true,
          id: { not: courseId },
        },
      });

      if (codeExists) {
        throw new AppError('Course with this code already exists', 400);
      }
    }

    // Validate schedule if provided
    if (schedule) {
      this._validateSchedule(schedule);
    }

    // Update course and schedule in transaction
    const updatedCourse = await prisma.$transaction(async (tx) => {
      // Update course
      const course = await tx.course.update({
        where: { id: courseId },
        data: {
          ...(name && { name: name.trim() }),
          ...(code && { code: code.toUpperCase().trim() }),
          ...(description !== undefined && { description: description?.trim() }),
          ...(instructor && { instructor: instructor.trim() }),
          ...(color && { color }),
        },
      });

      // Update schedule if provided
      if (schedule) {
        // Delete existing schedule
        await tx.courseSchedule.deleteMany({
          where: { courseId },
        });

        // Create new schedule
        if (schedule.length > 0) {
          await tx.courseSchedule.createMany({
            data: schedule.map(s => ({
              courseId,
              dayOfWeek: s.dayOfWeek,
              startTime: s.startTime,
              endTime: s.endTime,
              room: s.room?.trim(),
            })),
          });
        }
      }

      return course;
    });

    return this.getCourseById(userId, courseId);
  }

  // Delete course (soft delete)
  static async deleteCourse(userId, courseId) {
    // Check if course exists and belongs to user
    await this.getCourseById(userId, courseId);

    // Soft delete course
    await prisma.course.update({
      where: { id: courseId },
      data: { isActive: false },
    });

    return { message: 'Course deleted successfully' };
  }

  // Get course statistics
  static async getCourseStats(userId, courseId) {
    const course = await this.getCourseById(userId, courseId);

    const stats = await prisma.attendance.groupBy({
      by: ['status'],
      where: {
        courseId,
        userId,
      },
      _count: {
        status: true,
      },
    });

    const totalAttendance = stats.reduce((sum, stat) => sum + stat._count.status, 0);
    const presentCount = stats.find(s => s.status === 'PRESENT')?._count.status || 0;
    const lateCount = stats.find(s => s.status === 'LATE')?._count.status || 0;
    const absentCount = stats.find(s => s.status === 'ABSENT')?._count.status || 0;
    const excusedCount = stats.find(s => s.status === 'EXCUSED')?._count.status || 0;

    const attendanceRate = totalAttendance > 0
      ? ((presentCount + lateCount) / totalAttendance) * 100
      : 0;

    return {
      course: {
        id: course.id,
        name: course.name,
        code: course.code,
      },
      statistics: {
        totalClasses: totalAttendance,
        presentCount,
        lateCount,
        absentCount,
        excusedCount,
        attendanceRate: Math.round(attendanceRate * 100) / 100,
      },
    };
  }

  // Private helper methods
  static async _checkSubscriptionLimits(userId) {
    if (process.env.SUBSCRIPTION_ENABLED === 'false') {
      return; // Bypass limits when subscription is disabled
    }
    
    // Import subscription service
    const { subscriptionService } = await import('./subscriptionService.js');
    
    try {
      const subscription = await subscriptionService.getSubscription(userId);

      if (!subscription || subscription.status !== 'ACTIVE') {
        throw new AppError('No active subscription found', 403);
      }

      if (subscription.plan === 'FREE') {
        const courseCount = await prisma.course.count({
          where: { userId, isActive: true },
        });

        // Get current plan features
        const planFeatures = await subscriptionService.getPlanFeatures(subscription.plan);
        const courseLimit = 2; // Free plan limit

        if (courseCount >= courseLimit) {
          throw new AppError(
            `Free plan allows maximum ${courseLimit} courses. Change to Premium plan for unlimited courses.`,
            403
          );
        }
      }
    } catch (error) {
      if (error.statusCode === 404) {
        // User doesn't have subscription, create a FREE one
        await subscriptionService.createSubscription({
          userId,
          plan: 'FREE',
        });
        
        // Check limits again for FREE plan
        const courseCount = await prisma.course.count({
          where: { userId, isActive: true },
        });

        if (courseCount >= 2) {
          throw new AppError(
            'Free plan allows maximum 2 courses. Change to Premium plan for unlimited courses.',
            403
          );
        }
      } else {
        throw error;
      }
    }
  }

  static _validateSchedule(schedule) {
    if (!Array.isArray(schedule)) {
      throw new AppError('Schedule must be an array', 400);
    }

    for (const item of schedule) {
      if (
        typeof item.dayOfWeek !== 'number' ||
        item.dayOfWeek < 0 ||
        item.dayOfWeek > 6
      ) {
        throw new AppError('Invalid day of week (0-6)', 400);
      }

      if (!item.startTime || !item.endTime) {
        throw new AppError('Start time and end time are required', 400);
      }

      // Validate time format (HH:MM)
      const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (!timeRegex.test(item.startTime) || !timeRegex.test(item.endTime)) {
        throw new AppError('Invalid time format. Use HH:MM', 400);
      }

      // Check if start time is before end time
      const start = new Date(`2000-01-01T${item.startTime}:00`);
      const end = new Date(`2000-01-01T${item.endTime}:00`);
      if (start >= end) {
        throw new AppError('Start time must be before end time', 400);
      }
    }
  }
}

// Export the class for static method usage
export const courseService = CourseService; 