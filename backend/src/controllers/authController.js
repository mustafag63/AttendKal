import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { AppError, catchAsync } from '../middleware/errorHandler.js';
import { logger } from '../config/logger.js';
import ApiResponse from '../utils/apiResponse.js';

const prisma = new PrismaClient();

// Generate JWT token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });
};

// Generate refresh token
const generateRefreshToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRE,
  });
};

// Create and send token response
const createSendToken = async (user, statusCode, res, req) => {
  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  // Store refresh token in database
  await prisma.userSession.create({
    data: {
      userId: user.id,
      refreshToken,
      userAgent: req.headers['user-agent'] || '',
      ipAddress: req.ip || '',
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    },
  });

  // Remove password from output
  const { password: _password, ...userWithoutPassword } = user;

  return ApiResponse.success(res, {
    user: userWithoutPassword,
    token,
    refreshToken,
  }, 'Authentication successful', statusCode);
};

// Register new user
export const register = catchAsync(async (req, res, next) => {
  const { name, email, password, confirmPassword } = req.body;

  // Basic validation
  if (!name || !email || !password || !confirmPassword) {
    return next(new AppError('Please provide name, email, password and confirm password', 400));
  }

  if (password !== confirmPassword) {
    return next(new AppError('Passwords do not match', 400));
  }

  if (password.length < 6) {
    return next(new AppError('Password must be at least 6 characters long', 400));
  }

  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email: email.toLowerCase() },
  });

  if (existingUser) {
    return next(new AppError('User with this email already exists', 400));
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS) || 12);

  // Create user
  const user = await prisma.user.create({
    data: {
      name,
      email: email.toLowerCase(),
      password: hashedPassword,
      role: 'STUDENT',
    },
  });

  // Create free subscription for new user
  await prisma.subscription.create({
    data: {
      userId: user.id,
      type: 'FREE',
      isActive: true,
    },
  });

  logger.info(`New user registered: ${user.email}`);
  createSendToken(user, 201, res, req);
});

// Login user
export const login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  // Check if email and password exist
  if (!email || !password) {
    return next(new AppError('Please provide email and password', 400));
  }

  // Check if user exists and password is correct
  const user = await prisma.user.findUnique({
    where: { email: email.toLowerCase() },
  });

  if (!user || !(await bcrypt.compare(password, user.password))) {
    return next(new AppError('Incorrect email or password', 401));
  }

  if (!user.isActive) {
    return next(new AppError('Your account has been deactivated. Please contact support.', 401));
  }

  logger.info(`User logged in: ${user.email}`);
  createSendToken(user, 200, res, req);
});

// Logout user
export const logout = catchAsync(async (req, res, next) => {
  const { refreshToken } = req.body;

  if (refreshToken) {
    // Deactivate the refresh token
    await prisma.userSession.updateMany({
      where: {
        refreshToken,
        userId: req.user.id,
      },
      data: {
        isActive: false,
      },
    });
  }

  logger.info(`User logged out: ${req.user.email}`);
  res.status(200).json({
    status: 'success',
    message: 'Logged out successfully',
  });
});

// Refresh token
export const refreshToken = catchAsync(async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return next(new AppError('Please provide refresh token', 400));
  }

  // Verify refresh token
  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

  // Check if session exists and is active
  const session = await prisma.userSession.findFirst({
    where: {
      refreshToken,
      userId: decoded.id,
      isActive: true,
      expiresAt: {
        gt: new Date(),
      },
    },
    include: {
      user: true,
    },
  });

  if (!session) {
    return next(new AppError('Invalid or expired refresh token', 401));
  }

  // Generate new tokens
  const newToken = generateToken(session.user.id);
  const newRefreshToken = generateRefreshToken(session.user.id);

  // Update session with new refresh token
  await prisma.userSession.update({
    where: { id: session.id },
    data: {
      refreshToken: newRefreshToken,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    },
  });

  // Remove password from user object
  const { password: _password, ...userWithoutPassword } = session.user;

  res.status(200).json({
    status: 'success',
    data: {
      user: userWithoutPassword,
      token: newToken,
      refreshToken: newRefreshToken,
    },
  });
});

// Get current user
export const getMe = catchAsync(async (req, res, next) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
    select: {
      id: true,
      email: true,
      name: true,
      avatar: true,
      role: true,
      createdAt: true,
      subscription: {
        select: {
          type: true,
          isActive: true,
          endDate: true,
        },
      },
      _count: {
        select: {
          courses: true,
        },
      },
    },
  });

  res.status(200).json({
    status: 'success',
    data: {
      user,
    },
  });
});

// Update password
export const updatePassword = catchAsync(async (req, res, next) => {
  const { currentPassword, newPassword, confirmNewPassword } = req.body;

  if (!currentPassword || !newPassword || !confirmNewPassword) {
    return next(new AppError('Please provide current password, new password and confirm new password', 400));
  }

  if (newPassword !== confirmNewPassword) {
    return next(new AppError('New passwords do not match', 400));
  }

  if (newPassword.length < 6) {
    return next(new AppError('New password must be at least 6 characters long', 400));
  }

  // Get user with password
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
  });

  // Check current password
  if (!(await bcrypt.compare(currentPassword, user.password))) {
    return next(new AppError('Current password is incorrect', 401));
  }

  // Hash new password
  const hashedPassword = await bcrypt.hash(newPassword, parseInt(process.env.BCRYPT_ROUNDS) || 12);

  // Update password
  await prisma.user.update({
    where: { id: req.user.id },
    data: { password: hashedPassword },
  });

  // Deactivate all sessions (force re-login)
  await prisma.userSession.updateMany({
    where: { userId: req.user.id },
    data: { isActive: false },
  });

  logger.info(`Password updated for user: ${user.email}`);
  res.status(200).json({
    status: 'success',
    message: 'Password updated successfully. Please log in again.',
  });
});

// Update profile
export const updateProfile = catchAsync(async (req, res, next) => {
  const { name, avatar } = req.body;

  if (!name) {
    return next(new AppError('Please provide name', 400));
  }

  const updatedUser = await prisma.user.update({
    where: { id: req.user.id },
    data: {
      name,
      ...(avatar && { avatar }),
    },
    select: {
      id: true,
      email: true,
      name: true,
      avatar: true,
      role: true,
      createdAt: true,
    },
  });

  res.status(200).json({
    status: 'success',
    data: {
      user: updatedUser,
    },
  });
}); 