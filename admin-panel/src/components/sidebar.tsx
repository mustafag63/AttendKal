'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import {
    LayoutDashboard,
    Users,
    BookOpen,
    ClipboardCheck,
    Settings,
    Calendar,
    BarChart3,
    Database,
    Shield,
    Bell,
    FileText
} from 'lucide-react';

const sidebarItems = [
    {
        name: 'Dashboard',
        href: '/dashboard',
        icon: LayoutDashboard,
    },
    {
        name: 'Users',
        href: '/dashboard/users',
        icon: Users,
    },
    {
        name: 'Courses',
        href: '/dashboard/courses',
        icon: BookOpen,
    },
    {
        name: 'Attendance',
        href: '/dashboard/attendance',
        icon: ClipboardCheck,
    },
    {
        name: 'Analytics',
        href: '/dashboard/analytics',
        icon: BarChart3,
    },
    {
        name: 'Reports',
        href: '/dashboard/reports',
        icon: FileText,
    },
    {
        name: 'System',
        href: '/dashboard/system',
        icon: Database,
    },
    {
        name: 'Security',
        href: '/dashboard/security',
        icon: Shield,
    },
    {
        name: 'Notifications',
        href: '/dashboard/notifications',
        icon: Bell,
    },
    {
        name: 'Settings',
        href: '/dashboard/settings',
        icon: Settings,
    },
];

interface SidebarProps {
    className?: string;
}

export function Sidebar({ className }: SidebarProps) {
    const pathname = usePathname();

    return (
        <div className={cn('flex flex-col h-full bg-white border-r', className)}>
            {/* Logo */}
            <div className="flex items-center h-16 px-6 border-b">
                <Calendar className="h-8 w-8 text-primary mr-3" />
                <div>
                    <h1 className="text-lg font-semibold">AttendKal</h1>
                    <p className="text-xs text-muted-foreground">Admin Panel</p>
                </div>
            </div>

            {/* Navigation */}
            <nav className="flex-1 px-4 py-6 space-y-2">
                {sidebarItems.map((item) => {
                    const Icon = item.icon;
                    const isActive = pathname === item.href;

                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                'flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors',
                                isActive
                                    ? 'bg-primary text-primary-foreground'
                                    : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900'
                            )}
                        >
                            <Icon className="mr-3 h-5 w-5" />
                            {item.name}
                        </Link>
                    );
                })}
            </nav>

            {/* Footer */}
            <div className="p-4 border-t">
                <p className="text-xs text-muted-foreground text-center">
                    AttendKal Admin v1.0
                </p>
            </div>
        </div>
    );
} 