/**
 * Standard API Response Utilities
 * Provides consistent response structure across all endpoints
 */

export class ApiResponse {
    constructor(success, statusCode, message, data = null, errors = null) {
        this.success = success;
        this.statusCode = statusCode;
        this.message = message;
        this.data = data;
        this.errors = errors;
        this.timestamp = new Date().toISOString();
    }

    static success(res, data = null, message = 'Success', statusCode = 200) {
        return res.status(statusCode).json(
            new ApiResponse(true, statusCode, message, data)
        );
    }

    static error(res, message = 'Internal Server Error', statusCode = 500, errors = null) {
        return res.status(statusCode).json(
            new ApiResponse(false, statusCode, message, null, errors)
        );
    }

    static created(res, data = null, message = 'Resource created successfully') {
        return res.status(201).json(
            new ApiResponse(true, 201, message, data)
        );
    }

    static noContent(res, message = 'No content') {
        return res.status(204).json(
            new ApiResponse(true, 204, message)
        );
    }

    static badRequest(res, message = 'Bad request', errors = null) {
        return res.status(400).json(
            new ApiResponse(false, 400, message, null, errors)
        );
    }

    static unauthorized(res, message = 'Unauthorized') {
        return res.status(401).json(
            new ApiResponse(false, 401, message)
        );
    }

    static forbidden(res, message = 'Forbidden') {
        return res.status(403).json(
            new ApiResponse(false, 403, message)
        );
    }

    static notFound(res, message = 'Resource not found') {
        return res.status(404).json(
            new ApiResponse(false, 404, message)
        );
    }

    static conflict(res, message = 'Conflict') {
        return res.status(409).json(
            new ApiResponse(false, 409, message)
        );
    }

    static validationError(res, errors, message = 'Validation failed') {
        return res.status(422).json(
            new ApiResponse(false, 422, message, null, errors)
        );
    }

    static tooManyRequests(res, message = 'Too many requests') {
        return res.status(429).json(
            new ApiResponse(false, 429, message)
        );
    }

    static internalServerError(res, message = 'Internal server error') {
        return res.status(500).json(
            new ApiResponse(false, 500, message)
        );
    }

    static serviceUnavailable(res, message = 'Service unavailable') {
        return res.status(503).json(
            new ApiResponse(false, 503, message)
        );
    }
}

/**
 * Pagination metadata for list responses
 */
export class PaginationMeta {
    constructor(page, limit, total, totalPages) {
        this.page = parseInt(page);
        this.limit = parseInt(limit);
        this.total = parseInt(total);
        this.totalPages = parseInt(totalPages);
        this.hasNext = this.page < this.totalPages;
        this.hasPrev = this.page > 1;
    }
}

/**
 * Paginated response wrapper
 */
export const paginatedResponse = (res, data, page, limit, total, message = 'Success') => {
    const totalPages = Math.ceil(total / limit);
    const meta = new PaginationMeta(page, limit, total, totalPages);

    return ApiResponse.success(res, {
        items: data,
        pagination: meta
    }, message);
};

export default ApiResponse; 