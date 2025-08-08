// Token storage utilities
export const getToken = (): string | null => {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('accessToken');
};

export const setToken = (token: string): void => {
    if (typeof window !== 'undefined') {
        localStorage.setItem('accessToken', token);
    }
};

export const removeToken = (): void => {
    if (typeof window !== 'undefined') {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
    }
};

export const setRefreshToken = (token: string): void => {
    if (typeof window !== 'undefined') {
        localStorage.setItem('refreshToken', token);
    }
};

export const isAuthenticated = (): boolean => {
    return !!getToken();
}; 