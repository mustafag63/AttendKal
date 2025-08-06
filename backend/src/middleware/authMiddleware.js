import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { AppError, catchAsync } from './errorHandler.js';

const prisma = new PrismaClient();

// Verify JWT token and protect routes
export const authenticate = catchAsync(async (req, res, next) => {
    // 1) Getting token and check if it's there
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
        return next(new AppError('You are not logged in! Please log in to get access.', 401));
    }

    // 2) Verification token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 3) Check if user still exists
    const currentUser = await prisma.user.findUnique({
        where: { id: decoded.id },
        select: {
            id: true,
            email: true,
            name: true,
            role: true,
            isActive: true,
        },
    });

    if (!currentUser) {
        return next(new AppError('The user belonging to this token does no longer exist.', 401));
    }

    if (!currentUser.isActive) {
        return next(new AppError('Your account has been deactivated. Please contact support.', 401));
    }

    // 4) Grant access to protected route
    req.user = currentUser;
    next();
});

// Restrict to certain roles
export const restrictTo = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return next(new AppError('You do not have permission to perform this action', 403));
        }
        next();
    };
};

// Check if user owns the resource or is admin
export const checkOwnership = (resourceUserIdField = 'userId') => {
    return catchAsync(async (req, res, next) => {
        const resourceId = req.params.id;
        const userId = req.user.id;
        const userRole = req.user.role;

        // Admin can access everything
        if (userRole === 'ADMIN') {
            return next();
        }

        // For other endpoints, we need to check ownership
        let resource;

        // Determine which model to check based on the route
        if (req.route.path.includes('courses')) {
            resource = await prisma.course.findUnique({ where: { id: resourceId } });
        } else if (req.route.path.includes('attendance')) {
            resource = await prisma.attendance.findUnique({ where: { id: resourceId } });
        } else if (req.route.path.includes('subscriptions')) {
            resource = await prisma.subscription.findUnique({ where: { id: resourceId } });
        }

        if (!resource) {
            return next(new AppError('Resource not found', 404));
        }

        if (resource[resourceUserIdField] !== userId) {
            return next(new AppError('You do not have permission to access this resource', 403));
        }

        next();
    });
};

// Optional authentication (for public routes that can benefit from user info)
export const optionalAuth = catchAsync(async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
    }

    if (token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const currentUser = await prisma.user.findUnique({
                where: { id: decoded.id },
                select: {
                    id: true,
                    email: true,
                    name: true,
                    role: true,
                    isActive: true,
                },
            });

            if (currentUser && currentUser.isActive) {
                req.user = currentUser;
            }
        } catch (error) {
            // Token is invalid, but that's okay for optional auth
            // Just continue without user
        }
    }

    next();
}); 