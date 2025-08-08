import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/axios';
import { Course, CreateCourse, UpdateCourse } from '@/lib/zod-schemas';
import { ApiError } from '@/lib/types';
import { toast } from 'sonner';

// API functions
const coursesApi = {
    getCourses: async (params: {
        search?: string;
        page?: number;
        limit?: number;
    } = {}): Promise<{ courses: Course[]; total: number; page: number; totalPages: number }> => {
        const searchParams = new URLSearchParams();
        if (params.search) searchParams.append('search', params.search);
        if (params.page) searchParams.append('page', params.page.toString());
        if (params.limit) searchParams.append('limit', params.limit.toString());

        const response = await apiClient.get(`/api/courses?${searchParams.toString()}`);
        return response.data;
    },

    createCourse: async (course: CreateCourse): Promise<Course> => {
        const response = await apiClient.post('/api/courses', course);
        return response.data;
    },

    updateCourse: async ({ id, ...course }: UpdateCourse & { id: string }): Promise<Course> => {
        const response = await apiClient.put(`/api/courses/${id}`, course);
        return response.data;
    },

    deleteCourse: async (id: string): Promise<void> => {
        await apiClient.delete(`/api/courses/${id}`);
    },
};

// Custom hooks
export const useCourses = (params: {
    search?: string;
    page?: number;
    limit?: number;
} = {}) => {
    return useQuery({
        queryKey: ['courses', params],
        queryFn: () => coursesApi.getCourses(params),
        staleTime: 5 * 60 * 1000, // 5 minutes
    });
};

export const useCreateCourse = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: coursesApi.createCourse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['courses'] });
            toast.success('Course created successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to create course';
            toast.error(message);
        },
    });
};

export const useUpdateCourse = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: coursesApi.updateCourse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['courses'] });
            toast.success('Course updated successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to update course';
            toast.error(message);
        },
    });
};

export const useDeleteCourse = () => {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: coursesApi.deleteCourse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['courses'] });
            toast.success('Course deleted successfully');
        },
        onError: (error: ApiError) => {
            const message = error.response?.data?.message || 'Failed to delete course';
            toast.error(message);
        },
    });
}; 