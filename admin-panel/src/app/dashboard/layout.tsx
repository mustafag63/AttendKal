'use client';

import { useState } from 'react';
import { AuthGuard } from '@/components/auth-guard';
import { Sidebar } from '@/components/sidebar';
import { Topbar } from '@/components/topbar';

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const [sidebarOpen, setSidebarOpen] = useState(false);

    return (
        <AuthGuard requireRole="admin">
            <div className="h-screen flex bg-gray-50">
                {/* Desktop Sidebar */}
                <div className="hidden md:flex md:w-64 md:flex-col">
                    <Sidebar />
                </div>

                {/* Mobile Sidebar Overlay */}
                {sidebarOpen && (
                    <div className="fixed inset-0 z-50 md:hidden">
                        <div
                            className="absolute inset-0 bg-black opacity-50"
                            onClick={() => setSidebarOpen(false)}
                        />
                        <div className="relative w-64 h-full">
                            <Sidebar />
                        </div>
                    </div>
                )}

                {/* Main Content */}
                <div className="flex-1 flex flex-col overflow-hidden">
                    <Topbar onMenuClick={() => setSidebarOpen(true)} />

                    <main className="flex-1 overflow-auto p-6">
                        {children}
                    </main>
                </div>
            </div>
        </AuthGuard>
    );
} 