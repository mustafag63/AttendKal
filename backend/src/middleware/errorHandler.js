import { logger } from '../config/logger.js';

// Custom error class
export class AppError extends Error {
  constructor(message, statusCode = 500, isOperational = true, validationErrors = null) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.validationErrors = validationErrors;

    Error.captureStackTrace(this, this.constructor);
  }
}

// Handle Prisma errors
const handlePrismaError = (error) => {
  switch (error.code) {
  case 'P2002':
    return new AppError(
      `Duplicate field value: ${error.meta?.target?.join(', ') || 'unknown field'}`,
      400
    );
  case 'P2014':
    return new AppError('Invalid ID provided', 400);
  case 'P2003':
    return new AppError('Foreign key constraint failed', 400);
  case 'P2025':
    return new AppError('Record not found', 404);
  default:
    return new AppError('Database operation failed', 500);
  }
};

// Handle JWT errors
const handleJWTError = () => new AppError('Invalid token. Please log in again!', 401);
const handleJWTExpiredError = () => new AppError('Your token has expired! Please log in again.', 401);

// Handle validation errors
const handleValidationError = (error) => {
  const errors = error.errors?.map(err => err.message) || [error.message];
  return new AppError(`Validation Error: ${errors.join('. ')}`, 400);
};

// Send error response for development
const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,
    message: err.message,
    stack: err.stack,
  });
};

// Send error response for production
const sendErrorProd = (err, res) => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    const errorResponse = {
      status: err.status,
      message: err.message,
    };

    // Add validation errors if present
    if (err.validationErrors) {
      errorResponse.validationErrors = err.validationErrors;
    }

    res.status(err.statusCode).json(errorResponse);
  } else {
    // Programming or other unknown error: don't leak error details
    logger.error('ERROR 💥:', err);
    res.status(500).json({
      status: 'error',
      message: 'Something went wrong!',
    });
  }
};

// Global error handling middleware
export const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else {
    let error = { ...err };
    error.message = err.message;

    // Handle specific error types
    if (err.name === 'PrismaClientKnownRequestError') {
      error = handlePrismaError(err);
    } else if (err.name === 'JsonWebTokenError') {
      error = handleJWTError();
    } else if (err.name === 'TokenExpiredError') {
      error = handleJWTExpiredError();
    } else if (err.name === 'ValidationError') {
      error = handleValidationError(err);
    }

    sendErrorProd(error, res);
  }

  // Log the error
  logger.error(`${err.statusCode || 500} - ${err.message} - ${req.originalUrl} - ${req.method} - ${req.ip}`);
};

// Handle 404 errors
export const notFoundHandler = (req, res, next) => {
  const err = new AppError(`Can't find ${req.originalUrl} on this server!`, 404);
  next(err);
};

// Async error catcher
export const catchAsync = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
}; 