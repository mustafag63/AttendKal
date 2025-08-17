import { Request, Response, NextFunction } from 'express';
import { isDevelopment } from '@src/config/env';

export interface ApiError extends Error {
    statusCode?: number;
    isOperational?: boolean;
}

export class AppError extends Error implements ApiError {
    statusCode: number;
    isOperational: boolean;

    constructor(message: string, statusCode: number) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;

        Error.captureStackTrace(this, this.constructor);
    }
}

export const errorHandler = (
    err: ApiError,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    let { statusCode = 500, message } = err;

    if (!err.isOperational) {
        statusCode = 500;
        message = isDevelopment ? err.message : 'Internal Server Error';
    }

    const response = {
        success: false,
        error: {
            message,
            ...(isDevelopment && { stack: err.stack }),
        },
    };

    if (isDevelopment) {
        console.error('Error:', err);
    }

    res.status(statusCode).json(response);
};

export const asyncHandler = (fn: Function) => (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};
