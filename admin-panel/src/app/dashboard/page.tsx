'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
    Users,
    BookOpen,
    CheckCircle,
    TrendingUp,
    Plus,
    Settings,
    AlertTriangle,
    Activity,
    BarChart3,
    Calendar,
    Clock,
    Shield,
    Database,
    Bell,
    RefreshCw,
    Eye,
    Edit,
    Trash2,
    Download
} from 'lucide-react';

// Mock data - TODO: Replace with real API calls
const mockStats = {
    totalUsers: 142,
    totalCourses: 12,
    attendanceRate: 89.5,
    weeklyGrowth: 12.5,
    activeUsers: 87,
    totalSessions: 234,
    systemHealth: 'healthy',
    securityAlerts: 2,
};

const recentActivities = [
    {
        id: 1,
        type: 'user_registration',
        user: 'john.doe@email.com',
        action: 'New user registered',
        timestamp: '2 minutes ago',
        status: 'success',
    },
    {
        id: 2,
        type: 'course_update',
        user: 'admin@attendkal.com',
        action: 'Updated Mathematics 101 schedule',
        timestamp: '15 minutes ago',
        status: 'info',
    },
    {
        id: 3,
        type: 'security',
        user: 'system',
        action: 'Failed login attempt detected',
        timestamp: '1 hour ago',
        status: 'warning',
    },
    {
        id: 4,
        type: 'attendance',
        user: 'jane.smith@email.com',
        action: 'Marked attendance for Physics Lab',
        timestamp: '2 hours ago',
        status: 'success',
    },
];

const quickActions = [
    {
        title: 'Add New User',
        description: 'Create a new user account',
        icon: Users,
        href: '/dashboard/users',
        color: 'bg-blue-500',
    },
    {
        title: 'Create Course',
        description: 'Add a new course to the system',
        icon: BookOpen,
        href: '/dashboard/courses',
        color: 'bg-green-500',
    },
    {
        title: 'Mark Attendance',
        description: 'Record student attendance',
        icon: CheckCircle,
        href: '/dashboard/attendance',
        color: 'bg-purple-500',
    },
    {
        title: 'View Analytics',
        description: 'Analyze performance metrics',
        icon: BarChart3,
        href: '/dashboard/analytics',
        color: 'bg-orange-500',
    },
    {
        title: 'Security Check',
        description: 'Review security settings',
        icon: Shield,
        href: '/dashboard/security',
        color: 'bg-red-500',
    },
    {
        title: 'System Status',
        description: 'Monitor system health',
        icon: Database,
        href: '/dashboard/system',
        color: 'bg-gray-500',
    },
];

const systemAlerts = [
    {
        id: 1,
        type: 'warning',
        title: 'High Memory Usage',
        message: 'System memory usage is at 89%. Consider optimizing or scaling.',
        timestamp: '5 minutes ago',
    },
    {
        id: 2,
        type: 'info',
        title: 'Scheduled Maintenance',
        message: 'Database backup scheduled for tonight at 2:00 AM.',
        timestamp: '1 hour ago',
    },
];

const getActivityIcon = (type: string) => {
    switch (type) {
        case 'user_registration':
            return <Users className="w-4 h-4" />;
        case 'course_update':
            return <BookOpen className="w-4 h-4" />;
        case 'security':
            return <Shield className="w-4 h-4" />;
        case 'attendance':
            return <CheckCircle className="w-4 h-4" />;
        default:
            return <Activity className="w-4 h-4" />;
    }
};

const getActivityColor = (status: string) => {
    switch (status) {
        case 'success':
            return 'text-green-600 bg-green-100';
        case 'warning':
            return 'text-yellow-600 bg-yellow-100';
        case 'info':
            return 'text-blue-600 bg-blue-100';
        case 'error':
            return 'text-red-600 bg-red-100';
        default:
            return 'text-gray-600 bg-gray-100';
    }
};

export default function DashboardPage() {
    const [refreshing, setRefreshing] = useState(false);

    const handleRefresh = async () => {
        setRefreshing(true);
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000));
        setRefreshing(false);
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-600">Welcome back! Here&apos;s your system overview.</p>
                </div>
                <div className="flex space-x-3">
                    <Button
                        variant="outline"
                        onClick={handleRefresh}
                        disabled={refreshing}
                    >
                        <RefreshCw className={`w-4 h-4 mr-2 ${refreshing ? 'animate-spin' : ''}`} />
                        Refresh
                    </Button>
                    <Button asChild>
                        <Link href="/dashboard/analytics">
                            <BarChart3 className="w-4 h-4 mr-2" />
                            View Analytics
                        </Link>
                    </Button>
                </div>
            </div>

            {/* System Alerts */}
            {systemAlerts.length > 0 && (
                <div className="space-y-3">
                    {systemAlerts.map((alert) => (
                        <Card key={alert.id} className={
                            alert.type === 'warning' ? 'border-yellow-300 bg-yellow-50' : 'border-blue-300 bg-blue-50'
                        }>
                            <AlertTriangle className="h-4 w-4" />
                            <CardContent>
                                <div className="flex justify-between items-start">
                                    <div>
                                        <strong>{alert.title}:</strong> {alert.message}
                                    </div>
                                    <span className="text-xs text-gray-500">{alert.timestamp}</span>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}

            {/* KPI Cards */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <Card className="hover:shadow-lg transition-shadow">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Users</CardTitle>
                        <Users className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.totalUsers}</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +12% from last month
                        </div>
                        <div className="mt-2">
                            <Badge variant="outline" className="text-xs">
                                {mockStats.activeUsers} active
                            </Badge>
                        </div>
                    </CardContent>
                </Card>

                <Card className="hover:shadow-lg transition-shadow">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Courses</CardTitle>
                        <BookOpen className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.totalCourses}</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +2 this semester
                        </div>
                        <div className="mt-2">
                            <Badge variant="outline" className="text-xs">
                                All active
                            </Badge>
                        </div>
                    </CardContent>
                </Card>

                <Card className="hover:shadow-lg transition-shadow">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Attendance Rate</CardTitle>
                        <CheckCircle className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.attendanceRate}%</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +2.1% this week
                        </div>
                        <div className="mt-2">
                            <Badge variant="outline" className="text-xs">
                                Excellent
                            </Badge>
                        </div>
                    </CardContent>
                </Card>

                <Card className="hover:shadow-lg transition-shadow">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">System Health</CardTitle>
                        <Activity className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-600">Healthy</div>
                        <div className="flex items-center text-xs text-gray-600">
                            <Clock className="w-3 h-3 mr-1" />
                            Uptime: 7d 14h
                        </div>
                        <div className="mt-2">
                            <Badge variant="outline" className="text-xs text-green-700 border-green-300 bg-green-50">
                                All systems operational
                            </Badge>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Quick Actions Grid */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Settings className="w-5 h-5 mr-2" />
                        Quick Actions
                    </CardTitle>
                    <CardDescription>Common administrative tasks</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                        {quickActions.map((action) => {
                            const Icon = action.icon;
                            return (
                                <Link key={action.title} href={action.href}>
                                    <div className="flex items-center p-4 rounded-lg border border-gray-200 hover:bg-gray-50 hover:border-gray-300 transition-colors cursor-pointer group">
                                        <div className={`p-3 rounded-lg ${action.color} text-white mr-4 group-hover:scale-110 transition-transform`}>
                                            <Icon className="w-5 h-5" />
                                        </div>
                                        <div className="flex-1">
                                            <h3 className="font-medium text-gray-900">{action.title}</h3>
                                            <p className="text-sm text-gray-600">{action.description}</p>
                                        </div>
                                    </div>
                                </Link>
                            );
                        })}
                    </div>
                </CardContent>
            </Card>

            {/* Recent Activity & System Status */}
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Activity className="w-5 h-5 mr-2" />
                            Recent Activity
                        </CardTitle>
                        <CardDescription>Latest system events and user actions</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {recentActivities.map((activity) => (
                                <div key={activity.id} className="flex items-start space-x-3">
                                    <div className={`p-2 rounded-full ${getActivityColor(activity.status)}`}>
                                        {getActivityIcon(activity.type)}
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center justify-between">
                                            <p className="text-sm font-medium text-gray-900">
                                                {activity.action}
                                            </p>
                                            <span className="text-xs text-gray-500">{activity.timestamp}</span>
                                        </div>
                                        <p className="text-sm text-gray-600">{activity.user}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                        <div className="mt-4 pt-4 border-t">
                            <Button variant="outline" size="sm" className="w-full" asChild>
                                <Link href="/dashboard/security">
                                    <Eye className="w-4 h-4 mr-2" />
                                    View All Activity
                                </Link>
                            </Button>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Database className="w-5 h-5 mr-2" />
                            System Overview
                        </CardTitle>
                        <CardDescription>Current system status and metrics</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm font-medium">Database Status</p>
                                    <p className="text-xs text-gray-600">All connections healthy</p>
                                </div>
                                <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50">
                                    Operational
                                </Badge>
                            </div>

                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm font-medium">Active Sessions</p>
                                    <p className="text-xs text-gray-600">{mockStats.totalSessions} total sessions</p>
                                </div>
                                <Badge variant="outline" className="text-blue-700 border-blue-300 bg-blue-50">
                                    {mockStats.activeUsers} active
                                </Badge>
                            </div>

                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm font-medium">Security Alerts</p>
                                    <p className="text-xs text-gray-600">Last 24 hours</p>
                                </div>
                                <Badge variant="outline" className="text-yellow-700 border-yellow-300 bg-yellow-50">
                                    {mockStats.securityAlerts} alerts
                                </Badge>
                            </div>

                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm font-medium">System Version</p>
                                    <p className="text-xs text-gray-600">AttendKal Admin</p>
                                </div>
                                <Badge variant="outline">
                                    v1.2.3
                                </Badge>
                            </div>
                        </div>

                        <div className="mt-4 pt-4 border-t space-y-2">
                            <Button variant="outline" size="sm" className="w-full" asChild>
                                <Link href="/dashboard/system">
                                    <Settings className="w-4 h-4 mr-2" />
                                    System Management
                                </Link>
                            </Button>
                            <Button variant="outline" size="sm" className="w-full" asChild>
                                <Link href="/dashboard/security">
                                    <Shield className="w-4 h-4 mr-2" />
                                    Security Center
                                </Link>
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
} 