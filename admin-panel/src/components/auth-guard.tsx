'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useMe } from '@/hooks/useAuth';
import { isAuthenticated } from '@/lib/auth';

interface AuthGuardProps {
    children: React.ReactNode;
    requireRole?: 'admin' | 'user';
}

export function AuthGuard({ children, requireRole = 'admin' }: AuthGuardProps) {
    const router = useRouter();
    const { data: user, isLoading, error } = useMe();

    useEffect(() => {
        // If not authenticated, redirect to login
        if (!isAuthenticated()) {
            router.push('/login');
            return;
        }

        // If auth request failed (token invalid), redirect to login
        if (error) {
            router.push('/login');
            return;
        }

        // If user loaded but doesn't have required role, redirect to login
        if (user && user.role !== requireRole) {
            router.push('/login');
            return;
        }
    }, [user, error, router, requireRole]);

    // Show loading state while checking auth
    if (isLoading || !isAuthenticated()) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
        );
    }

    // Show loading if we don't have user data yet
    if (!user) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
        );
    }

    // User is authenticated and has correct role
    return <>{children}</>;
} 