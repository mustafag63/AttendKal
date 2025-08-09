import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../../utils/prisma.js';
import { AppError } from '../../middleware/errorHandler.js';

export class AuthService {
  // Generate JWT tokens
  static generateTokens(userId) {
    const accessToken = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRE,
    });

    const refreshToken = jwt.sign({ id: userId }, process.env.JWT_REFRESH_SECRET, {
      expiresIn: process.env.JWT_REFRESH_EXPIRE,
    });

    return { accessToken, refreshToken };
  }

  // Register new user
  static async registerUser({ name, email, password }) {
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (existingUser) {
      throw new AppError('User with this email already exists', 400);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(
      password,
      parseInt(process.env.BCRYPT_ROUNDS) || 12
    );

    // Create user transaction
    const result = await prisma.$transaction(async (tx) => {
      // Create user
      const user = await tx.user.create({
        data: {
          name,
          email: email.toLowerCase(),
          password: hashedPassword,
          role: 'STUDENT',
        },
      });

      // Create free subscription
      await tx.subscription.create({
        data: {
          userId: user.id,
          type: 'FREE',
        },
      });

      return user;
    });

    return result;
  }

  // Authenticate user
  static async authenticateUser({ email, password }) {
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new AppError('Incorrect email or password', 401);
    }

    if (!user.isActive) {
      throw new AppError('Your account has been deactivated', 401);
    }

    return user;
  }

  // Store refresh token session
  static async createSession(userId, refreshToken, req) {
    return prisma.userSession.create({
      data: {
        userId,
        refreshToken,
        userAgent: req.headers['user-agent'] || '',
        ipAddress: req.ip || '',
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      },
    });
  }

  // Refresh token
  static async refreshUserToken(refreshToken) {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    const session = await prisma.userSession.findFirst({
      where: {
        refreshToken,
        userId: decoded.id,
        isActive: true,
        expiresAt: { gt: new Date() },
      },
      include: { user: true },
    });

    if (!session) {
      throw new AppError('Invalid or expired refresh token', 401);
    }

    // Generate new tokens
    const { accessToken, refreshToken: newRefreshToken } =
      this.generateTokens(session.user.id);

    // Update session
    await prisma.userSession.update({
      where: { id: session.id },
      data: {
        refreshToken: newRefreshToken,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });

    return {
      user: session.user,
      accessToken,
      refreshToken: newRefreshToken,
    };
  }

  // Update password
  static async updateUserPassword(userId, currentPassword, newPassword) {
    const user = await prisma.user.findUnique({ where: { id: userId } });

    if (!(await bcrypt.compare(currentPassword, user.password))) {
      throw new AppError('Current password is incorrect', 401);
    }

    const hashedPassword = await bcrypt.hash(
      newPassword,
      parseInt(process.env.BCRYPT_ROUNDS) || 12
    );

    // Update password and deactivate all sessions
    await prisma.$transaction([
      prisma.user.update({
        where: { id: userId },
        data: { password: hashedPassword },
      }),
      prisma.userSession.updateMany({
        where: { userId },
        data: { isActive: false },
      }),
    ]);
  }
}

// Export the class for static method usage
export const authService = AuthService; 