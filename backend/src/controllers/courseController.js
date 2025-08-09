import { prisma } from '../utils/prisma.js';
import { AppError, catchAsync } from '../middleware/errorHandler.js';
import { logger } from '../config/logger.js';

// Get all courses for a user
export const getCourses = catchAsync(async (req, res) => {
  const { page = 1, limit = 10, search = '' } = req.query;
  const offset = (page - 1) * limit;

  const whereClause = {
    userId: req.user.id,
    isActive: true,
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { code: { contains: search, mode: 'insensitive' } },
        { instructor: { contains: search, mode: 'insensitive' } },
      ],
    }),
  };

  const [courses, total] = await Promise.all([
    prisma.course.findMany({
      where: whereClause,
      include: {
        schedule: true,
        _count: {
          select: {
            attendances: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: parseInt(offset),
      take: parseInt(limit),
    }),
    prisma.course.count({ where: whereClause }),
  ]);

  // Calculate attendance statistics for each course
  const coursesWithStats = await Promise.all(
    courses.map(async (course) => {
      const attendanceStats = await prisma.attendance.groupBy({
        by: ['status'],
        where: {
          courseId: course.id,
          userId: req.user.id,
        },
        _count: {
          status: true,
        },
      });

      const stats = {
        total: course._count.attendances,
        present: 0,
        absent: 0,
        late: 0,
        excused: 0,
      };

      attendanceStats.forEach((stat) => {
        stats[stat.status.toLowerCase()] = stat._count.status;
      });

      const attendanceRate =
        stats.total > 0 ? ((stats.present + stats.late) / stats.total) * 100 : 0;

      return {
        ...course,
        attendanceStats: stats,
        attendanceRate: Math.round(attendanceRate * 100) / 100,
      };
    })
  );

  res.status(200).json({
    status: 'success',
    data: {
      courses: coursesWithStats,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    },
  });
});

// Get a single course
export const getCourse = catchAsync(async (req, res, next) => {
  const { id } = req.params;

  const course = await prisma.course.findFirst({
    where: {
      id,
      userId: req.user.id,
      isActive: true,
    },
    include: {
      schedule: true,
      attendances: {
        orderBy: { date: 'desc' },
        take: 20,
      },
    },
  });

  if (!course) {
    return next(new AppError('Course not found', 404));
  }

  // Calculate attendance statistics
  const attendanceStats = await prisma.attendance.groupBy({
    by: ['status'],
    where: {
      courseId: course.id,
      userId: req.user.id,
    },
    _count: {
      status: true,
    },
  });

  const stats = {
    total: 0,
    present: 0,
    absent: 0,
    late: 0,
    excused: 0,
  };

  attendanceStats.forEach((stat) => {
    stats[stat.status.toLowerCase()] = stat._count.status;
    stats.total += stat._count.status;
  });

  const attendanceRate =
    stats.total > 0 ? ((stats.present + stats.late) / stats.total) * 100 : 0;

  res.status(200).json({
    status: 'success',
    data: {
      course: {
        ...course,
        attendanceStats: stats,
        attendanceRate: Math.round(attendanceRate * 100) / 100,
      },
    },
  });
});

// Create a new course
export const createCourse = catchAsync(async (req, res, next) => {
  const { name, code, description, instructor, color, schedule } = req.body;

  // Normalize inputs
  const normalizedName = name?.trim();
  const normalizedCode = code?.toUpperCase().trim();
  const normalizedInstructor = instructor?.trim();
  const normalizedDescription = description?.trim();

  // Validate required fields
  if (!normalizedName || !normalizedCode || !normalizedInstructor) {
    return next(new AppError('Please provide name, code and instructor', 400));
  }

  // Check if course code already exists for this user (case-insensitive)
  const existingCourse = await prisma.course.findFirst({
    where: {
      code: normalizedCode,
      userId: req.user.id,
      isActive: true,
    },
  });

  if (existingCourse) {
    return next(new AppError('Course with this code already exists', 400));
  }

  // Validate schedule if provided
  if (schedule && Array.isArray(schedule)) {
    for (const item of schedule) {
      const dayOfWeek = parseInt(item.dayOfWeek);

      if (
        isNaN(dayOfWeek) ||
        !item.startTime ||
        !item.endTime ||
        dayOfWeek < 0 ||
        dayOfWeek > 6
      ) {
        return next(new AppError('Invalid schedule format', 400));
      }

      // Normalize the dayOfWeek to ensure it's an integer
      item.dayOfWeek = dayOfWeek;
    }
  }

  // Create course with schedule
  const course = await prisma.course.create({
    data: {
      name: normalizedName,
      code: normalizedCode,
      description: normalizedDescription || '',
      instructor: normalizedInstructor,
      color: color || '#2196F3',
      userId: req.user.id,
      schedule: {
        create: schedule || [],
      },
    },
    include: {
      schedule: true,
    },
  });

  logger.info(`Course created: ${course.name} by user ${req.user.email}`);

  res.status(201).json({
    status: 'success',
    data: {
      course,
    },
  });
});

// Update a course
export const updateCourse = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const { name, code, description, instructor, color, schedule } = req.body;

  // Check if course exists and belongs to user
  const existingCourse = await prisma.course.findFirst({
    where: {
      id,
      userId: req.user.id,
      isActive: true,
    },
  });

  if (!existingCourse) {
    return next(new AppError('Course not found', 404));
  }

  // Check if new code conflicts with another course
  if (code && code.toUpperCase().trim() !== existingCourse.code) {
    const codeConflict = await prisma.course.findFirst({
      where: {
        code: code.toUpperCase().trim(),
        userId: req.user.id,
        isActive: true,
        NOT: { id },
      },
    });

    if (codeConflict) {
      return next(new AppError('Course with this code already exists', 400));
    }
  }

  // Update course
  const updateData = {};
  if (name) updateData.name = name.trim();
  if (code) updateData.code = code.toUpperCase().trim();
  if (description !== undefined) updateData.description = description?.trim();
  if (instructor) updateData.instructor = instructor.trim();
  if (color) updateData.color = color;

  // Handle schedule update
  if (schedule && Array.isArray(schedule)) {
    // Delete existing schedule
    await prisma.courseSchedule.deleteMany({
      where: { courseId: id },
    });
  }

  const course = await prisma.course.update({
    where: { id },
    data: {
      ...updateData,
      ...(schedule && Array.isArray(schedule) && {
        schedule: {
          create: schedule,
        },
      }),
    },
    include: {
      schedule: true,
    },
  });

  logger.info(`Course updated: ${course.name} by user ${req.user.email}`);

  res.status(200).json({
    status: 'success',
    data: {
      course,
    },
  });
});

// Delete a course (soft delete)
export const deleteCourse = catchAsync(async (req, res, next) => {
  const { id } = req.params;

  const course = await prisma.course.findFirst({
    where: {
      id,
      userId: req.user.id,
      isActive: true,
    },
  });

  if (!course) {
    return next(new AppError('Course not found', 404));
  }

  // Soft delete the course
  await prisma.course.update({
    where: { id },
    data: { isActive: false },
  });

  logger.info(`Course deleted: ${course.name} by user ${req.user.email}`);

  res.status(200).json({
    status: 'success',
    message: 'Course deleted successfully',
  });
});

// Get course statistics
export const getCourseStats = catchAsync(async (req, res) => {
  const userId = req.user.id;

  const [totalCourses, recentAttendance, overallStats] = await Promise.all([
    // Total courses count
    prisma.course.count({
      where: {
        userId,
        isActive: true,
      },
    }),

    // Recent attendance (last 7 days)
    prisma.attendance.findMany({
      where: {
        userId,
        date: {
          gte: new Date(new Date().setDate(new Date().getDate() - 7)),
        },
      },
      include: {
        course: {
          select: {
            name: true,
            color: true,
          },
        },
      },
      orderBy: { date: 'desc' },
    }),

    // Overall attendance statistics
    prisma.attendance.groupBy({
      by: ['status'],
      where: { userId },
      _count: {
        status: true,
      },
    }),
  ]);

  const stats = {
    total: 0,
    present: 0,
    absent: 0,
    late: 0,
    excused: 0,
  };

  overallStats.forEach((stat) => {
    stats[stat.status.toLowerCase()] = stat._count.status;
    stats.total += stat._count.status;
  });

  const overallAttendanceRate =
    stats.total > 0 ? ((stats.present + stats.late) / stats.total) * 100 : 0;

  res.status(200).json({
    status: 'success',
    data: {
      totalCourses,
      recentAttendance,
      overallStats: stats,
      overallAttendanceRate: Math.round(overallAttendanceRate * 100) / 100,
    },
  });
}); 