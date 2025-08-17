import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '@src/config/env';
import { AppError } from './error';

export interface AuthenticatedRequest extends Request {
    user?: {
        id: string;
        email: string;
    };
}

export const authenticate = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new AppError('Access token required', 401);
        }

        const token = authHeader.substring(7);

        const decoded = jwt.verify(token, config.jwtSecret) as any;

        req.user = {
            id: decoded.id,
            email: decoded.email,
        };

        next();
    } catch (error) {
        if (error instanceof jwt.JsonWebTokenError) {
            return next(new AppError('Invalid token', 401));
        }
        next(error);
    }
};

export const generateToken = (payload: { id: string; email: string }): string => {
    return jwt.sign(payload, config.jwtSecret, { expiresIn: '7d' });
};
