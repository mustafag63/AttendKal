import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/axios';
import { removeToken, setToken, setRefreshToken } from '@/lib/auth';
import { LoginCredentials, AuthResponse, UserMe } from '@/lib/zod-schemas';
import { ApiError } from '@/lib/types';
import { toast } from 'sonner';

// Auth API functions
const authApi = {
    login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
        const response = await apiClient.post('/api/auth/login', credentials);
        // Map backend shape to frontend auth shape
        return {
            accessToken: response.data?.data?.token,
            refreshToken: response.data?.data?.refreshToken,
        };
    },

    me: async (): Promise<UserMe> => {
        const response = await apiClient.get('/api/auth/me');
        const userData = response.data?.data?.user || response.data?.data;
        return {
            id: userData.id,
            email: userData.email,
            name: userData.name,
            role: userData.role?.toLowerCase() === 'admin' ? 'admin' : 'user',
        };
    },

    logout: async (): Promise<void> => {
        // TODO: Call logout endpoint if available
        // await apiClient.post('/api/auth/logout');
    },
};

// Custom hooks
export const useLogin = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: authApi.login,
        onSuccess: (data) => {
            setToken(data.accessToken);
            if (data.refreshToken) {
                setRefreshToken(data.refreshToken);
            }
            queryClient.invalidateQueries({ queryKey: ['auth', 'me'] });
            toast.success('Login successful');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Login failed';
            toast.error(message);
        },
    });
};

export const useMe = () => {
    return useQuery({
        queryKey: ['auth', 'me'],
        queryFn: authApi.me,
        retry: false,
        staleTime: 5 * 60 * 1000, // 5 minutes
    });
};

export const useLogout = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: authApi.logout,
        onSuccess: () => {
            removeToken();
            queryClient.clear();
            toast.success('Logged out successfully');

            // Redirect to login
            if (typeof window !== 'undefined') {
                window.location.href = '/login';
            }
        },
    });
}; 