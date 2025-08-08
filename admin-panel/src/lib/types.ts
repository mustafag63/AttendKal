export interface ApiError {
    response?: {
        status: number;
        data?: {
            message?: string;
        };
    };
    message: string;
}

export interface QueryError {
    response?: {
        status: number;
        data?: {
            message?: string;
        };
    };
    message: string;
} 