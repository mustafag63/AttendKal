import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import { config } from './config';
import { getToken, removeToken, setToken } from './auth';

// Create axios instance
export const apiClient = axios.create({
    baseURL: config.apiBaseUrl,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
        const token = getToken();
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error: AxiosError) => Promise.reject(error)
);

// Response interceptor for auth error handling
apiClient.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
        const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;

            try {
                // Try to refresh token if available
                const refreshToken = localStorage.getItem('refreshToken');
                if (refreshToken) {
                    const response = await axios.post(`${config.apiBaseUrl}/api/auth/refresh-token`, {
                        refreshToken,
                    });

                    const { token: accessToken, refreshToken: newRefreshToken } = response.data.data || {};
                    if (accessToken) {
                        setToken(accessToken);
                    }
                    if (newRefreshToken) {
                        localStorage.setItem('refreshToken', newRefreshToken);
                    }

                    // Retry original request with new token
                    if (accessToken) {
                        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
                    }
                    return apiClient(originalRequest);
                }
            } catch {
                // Refresh failed, redirect to login
                removeToken();
                if (typeof window !== 'undefined') {
                    window.location.href = '/login';
                }
            }
        }

        return Promise.reject(error);
    }
); 