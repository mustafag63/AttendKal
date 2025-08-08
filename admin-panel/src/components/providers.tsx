'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { Toaster } from '@/components/ui/sonner';
import { ApiError } from '@/lib/types';
import { useState } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
    const [queryClient] = useState(
        () =>
            new QueryClient({
                defaultOptions: {
                    queries: {
                        // With SSR, we usually want to set some default staleTime
                        // above 0 to avoid refetching immediately on the client
                        staleTime: 60 * 1000,
                        retry: (failureCount, error: unknown) => {
                            const apiError = error as ApiError;
                            // Don't retry on 401, 403, 404
                            if (apiError?.response?.status === 401 ||
                                apiError?.response?.status === 403 ||
                                apiError?.response?.status === 404) {
                                return false;
                            }
                            return failureCount < 3;
                        },
                    },
                },
            })
    );

    return (
        <QueryClientProvider client={queryClient}>
            {children}
            <Toaster richColors position="top-right" />
            <ReactQueryDevtools initialIsOpen={false} />
        </QueryClientProvider>
    );
} 