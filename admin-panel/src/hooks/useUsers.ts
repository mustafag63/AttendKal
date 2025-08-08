import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/axios';
import { User, CreateUser, UpdateUser } from '@/lib/zod-schemas';
import { ApiError } from '@/lib/types';
import { toast } from 'sonner';

// API functions
const usersApi = {
    getUsers: async (params: {
        search?: string;
        page?: number;
        limit?: number;
    } = {}): Promise<{ users: User[]; total: number; page: number; totalPages: number }> => {
        const searchParams = new URLSearchParams();
        if (params.search) searchParams.append('search', params.search);
        if (params.page) searchParams.append('page', params.page.toString());
        if (params.limit) searchParams.append('limit', params.limit.toString());

        const response = await apiClient.get(`/api/users?${searchParams.toString()}`);
        return response.data;
    },

    createUser: async (user: CreateUser): Promise<User> => {
        const response = await apiClient.post('/api/users', user);
        return response.data;
    },

    updateUser: async ({ id, ...user }: UpdateUser & { id: string }): Promise<User> => {
        const response = await apiClient.put(`/api/users/${id}`, user);
        return response.data;
    },

    deleteUser: async (id: string): Promise<void> => {
        await apiClient.delete(`/api/users/${id}`);
    },
};

// Custom hooks
export const useUsers = (params: {
    search?: string;
    page?: number;
    limit?: number;
} = {}) => {
    return useQuery({
        queryKey: ['users', params],
        queryFn: () => usersApi.getUsers(params),
        staleTime: 5 * 60 * 1000, // 5 minutes
    });
};

export const useCreateUser = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: usersApi.createUser,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['users'] });
            toast.success('User created successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to create user';
            toast.error(message);
        },
    });
};

export const useUpdateUser = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: usersApi.updateUser,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['users'] });
            toast.success('User updated successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to update user';
            toast.error(message);
        },
    });
};

export const useDeleteUser = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: usersApi.deleteUser,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['users'] });
            toast.success('User deleted successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to delete user';
            toast.error(message);
        },
    });
}; 