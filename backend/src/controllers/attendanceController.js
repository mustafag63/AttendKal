import { prisma } from '../utils/prisma.js';
import { AppError, catchAsync } from '../middleware/errorHandler.js';
import { logger } from '../config/logger.js';

// Get attendance records
export const getAttendance = catchAsync(async (req, res, next) => {
  const { courseId, page = 1, limit = 50 } = req.query;
  const offset = (page - 1) * limit;

  const whereClause = {
    userId: req.user.id,
    ...(courseId && { courseId }),
  };

  const [attendances, total] = await Promise.all([
    prisma.attendance.findMany({
      where: whereClause,
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            color: true,
          },
        },
      },
      orderBy: { date: 'desc' },
      skip: parseInt(offset),
      take: parseInt(limit),
    }),
    prisma.attendance.count({ where: whereClause }),
  ]);

  res.status(200).json({
    status: 'success',
    data: attendances,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
    },
  });
});

// Mark attendance
export const markAttendance = catchAsync(async (req, res, next) => {
  const { courseId, status, date, note } = req.body;

  // Validate required fields
  if (!courseId || !status || !date) {
    return next(new AppError('Please provide courseId, status, and date', 400));
  }

  // Validate status
  const validStatuses = ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'];
  if (!validStatuses.includes(status.toUpperCase())) {
    return next(new AppError('Invalid attendance status', 400));
  }

  // Check if course exists and belongs to user
  const course = await prisma.course.findFirst({
    where: {
      id: courseId,
      userId: req.user.id,
      isActive: true,
    },
  });

  if (!course) {
    return next(new AppError('Course not found', 404));
  }

  // Parse date
  const attendanceDate = new Date(date);
  if (isNaN(attendanceDate.getTime())) {
    return next(new AppError('Invalid date format', 400));
  }

  // Check if attendance already exists for this date
  const existingAttendance = await prisma.attendance.findFirst({
    where: {
      userId: req.user.id,
      courseId,
      date: {
        gte: new Date(attendanceDate.setHours(0, 0, 0, 0)),
        lt: new Date(attendanceDate.setHours(23, 59, 59, 999)),
      },
    },
  });

  let attendance;

  if (existingAttendance) {
    // Update existing attendance
    attendance = await prisma.attendance.update({
      where: { id: existingAttendance.id },
      data: {
        status: status.toUpperCase(),
        note: note || null,
      },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            color: true,
          },
        },
      },
    });
  } else {
    // Create new attendance record
    attendance = await prisma.attendance.create({
      data: {
        userId: req.user.id,
        courseId,
        date: new Date(date),
        status: status.toUpperCase(),
        note: note || null,
      },
      include: {
        course: {
          select: {
            id: true,
            name: true,
            code: true,
            color: true,
          },
        },
      },
    });
  }

  logger.info(`Attendance marked: ${status} for course ${course.name} by user ${req.user.email}`);

  res.status(200).json({
    status: 'success',
    data: attendance,
  });
});

// Get attendance statistics
export const getAttendanceStats = catchAsync(async (req, res, next) => {
  const { courseId } = req.query;
  const userId = req.user.id;

  const whereClause = {
    userId,
    ...(courseId && { courseId }),
  };

  // Get overall statistics
  const [attendanceStats, recentAttendance] = await Promise.all([
    prisma.attendance.groupBy({
      by: ['status'],
      where: whereClause,
      _count: {
        status: true,
      },
    }),
    prisma.attendance.findMany({
      where: {
        userId,
        date: {
          gte: new Date(new Date().setDate(new Date().getDate() - 30)), // Last 30 days
        },
      },
      include: {
        course: {
          select: {
            name: true,
            code: true,
            color: true,
          },
        },
      },
      orderBy: { date: 'desc' },
      take: 10,
    }),
  ]);

  const stats = {
    total: 0,
    present: 0,
    absent: 0,
    late: 0,
    excused: 0,
  };

  attendanceStats.forEach((stat) => {
    const status = stat.status.toLowerCase();
    stats[status] = stat._count.status;
    stats.total += stat._count.status;
  });

  const attendanceRate = stats.total > 0
    ? ((stats.present + stats.late) / stats.total * 100)
    : 0;

  res.status(200).json({
    status: 'success',
    data: {
      statistics: stats,
      attendanceRate: Math.round(attendanceRate * 100) / 100,
      recentAttendance,
    },
  });
});

// Delete attendance record
export const deleteAttendance = catchAsync(async (req, res, next) => {
  const { id } = req.params;

  const attendance = await prisma.attendance.findFirst({
    where: {
      id,
      userId: req.user.id,
    },
  });

  if (!attendance) {
    return next(new AppError('Attendance record not found', 404));
  }

  await prisma.attendance.delete({
    where: { id },
  });

  logger.info(`Attendance record deleted: ${id} by user ${req.user.email}`);

  res.status(200).json({
    status: 'success',
    message: 'Attendance record deleted successfully',
  });
}); 