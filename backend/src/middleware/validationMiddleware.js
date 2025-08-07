import { validationResult } from 'express-validator';
import { AppError } from './errorHandler.js';
import { logger } from '../config/logger.js';

// Validation result checker middleware
export const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.path || error.param,
      message: error.msg,
      value: error.value,
    }));

    logger.warn('Validation failed', {
      url: req.originalUrl,
      method: req.method,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      errors: errorMessages,
    });

    return next(new AppError('Validation failed', 400, true, errorMessages));
  }

  next();
};

// Sanitize input middleware
export const sanitizeInput = (req, res, next) => {
  const sanitizeObject = (obj) => {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }

    if (Array.isArray(obj)) {
      return obj.map(sanitizeObject);
    }

    const sanitized = {};
    for (const [key, value] of Object.entries(obj)) {
      if (typeof value === 'string') {
        // Remove potentially dangerous characters
        sanitized[key] = value
          .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
          .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
          .replace(/javascript:/gi, '')
          .replace(/on\w+\s*=/gi, '')
          .trim();
      } else {
        sanitized[key] = sanitizeObject(value);
      }
    }
    return sanitized;
  };

  // Sanitize request body
  if (req.body) {
    req.body = sanitizeObject(req.body);
  }

  // Sanitize query parameters
  if (req.query) {
    req.query = sanitizeObject(req.query);
  }

  // Sanitize route parameters
  if (req.params) {
    req.params = sanitizeObject(req.params);
  }

  next();
};

// File upload validation middleware
export const validateFileUpload = (options = {}) => {
  return (req, res, next) => {
    if (!req.files || req.files.length === 0) {
      if (options.required) {
        return next(new AppError('No file uploaded', 400));
      }
      return next();
    }

    const { maxSize = 5 * 1024 * 1024, allowedTypes = ['image/jpeg', 'image/png', 'image/gif'] } = options;

    for (const file of req.files) {
      // Check file size
      if (file.size > maxSize) {
        return next(new AppError(`File ${file.originalname} exceeds maximum size of ${maxSize / (1024 * 1024)}MB`, 400));
      }

      // Check file type
      if (!allowedTypes.includes(file.mimetype)) {
        return next(new AppError(`File type ${file.mimetype} is not allowed`, 400));
      }

      // Check for malicious file extensions
      const dangerousExtensions = ['.exe', '.bat', '.sh', '.php', '.asp', '.aspx', '.jsp', '.py', '.rb'];
      const fileExtension = file.originalname.toLowerCase().substring(file.originalname.lastIndexOf('.'));

      if (dangerousExtensions.includes(fileExtension)) {
        return next(new AppError(`File extension ${fileExtension} is not allowed`, 400));
      }
    }

    next();
  };
};

// Rate limiting validation
export const validateRateLimit = (req, res, next) => {
  // Add rate limiting metadata to request
  req.rateLimitInfo = {
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    endpoint: req.route?.path || req.path,
    method: req.method,
    timestamp: new Date(),
  };

  next();
};

// Request size validation
export const validateRequestSize = (maxSize = '10mb') => {
  return (req, res, next) => {
    const contentLength = parseInt(req.get('content-length') || '0');
    const maxSizeBytes = parseInt(maxSize) * 1024 * 1024; // Convert MB to bytes

    if (contentLength > maxSizeBytes) {
      logger.warn('Request size exceeded', {
        contentLength,
        maxSizeBytes,
        ip: req.ip,
        endpoint: req.originalUrl,
      });

      return next(new AppError('Request entity too large', 413));
    }

    next();
  };
};

// Custom validation helpers
export const customValidators = {
  isStrongPassword: (value) => {
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(value);
    const hasLowerCase = /[a-z]/.test(value);
    const hasNumbers = /\d/.test(value);
    const hasNonalphas = /\W/.test(value);

    if (value.length < minLength) {
      throw new Error(`Password must be at least ${minLength} characters long`);
    }

    if (!hasUpperCase) {
      throw new Error('Password must contain at least one uppercase letter');
    }

    if (!hasLowerCase) {
      throw new Error('Password must contain at least one lowercase letter');
    }

    if (!hasNumbers) {
      throw new Error('Password must contain at least one number');
    }

    return true;
  },

  isValidCourseCode: (value) => {
    const courseCodePattern = /^[A-Z]{2,4}\d{3,4}$/;
    if (!courseCodePattern.test(value)) {
      throw new Error('Course code must be in format like CS101 or MATH1234');
    }
    return true;
  },

  isValidColor: (value) => {
    const colorPattern = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;
    if (!colorPattern.test(value)) {
      throw new Error('Color must be a valid hex color code');
    }
    return true;
  },

  isValidTimeFormat: (value) => {
    const timePattern = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timePattern.test(value)) {
      throw new Error('Time must be in HH:MM format');
    }
    return true;
  },

  isValidDayOfWeek: (value) => {
    const dayOfWeek = parseInt(value);
    if (isNaN(dayOfWeek) || dayOfWeek < 0 || dayOfWeek > 6) {
      throw new Error('Day of week must be between 0 (Sunday) and 6 (Saturday)');
    }
    return true;
  },
};

// Validation error formatter
export const formatValidationErrors = (errors) => {
  return errors.array().reduce((acc, error) => {
    const field = error.path || error.param;
    if (!acc[field]) {
      acc[field] = [];
    }
    acc[field].push(error.msg);
    return acc;
  }, {});
}; 