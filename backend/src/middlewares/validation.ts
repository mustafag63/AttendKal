import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { AppError } from './error';

export const validate = (schema: ZodSchema) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            const validated = schema.parse(req.body);
            req.body = validated;
            next();
        } catch (error) {
            if (error instanceof ZodError) {
                const validationErrors = error.errors.map((err: any) => ({
                    field: err.path.join('.'),
                    message: err.message,
                }));

                return next(
                    new AppError(
                        `Validation failed: ${validationErrors.map((e: any) => e.message).join(', ')}`,
                        400
                    )
                );
            }
            next(error);
        }
    };
};

export const validateQuery = (schema: ZodSchema) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            const validated = schema.parse(req.query);
            req.query = validated as any;
            next();
        } catch (error) {
            if (error instanceof ZodError) {
                const validationErrors = error.errors.map((err: any) => ({
                    field: err.path.join('.'),
                    message: err.message,
                }));

                return next(
                    new AppError(
                        `Query validation failed: ${validationErrors.map((e: any) => e.message).join(', ')}`,
                        400
                    )
                );
            }
            next(error);
        }
    };
};
