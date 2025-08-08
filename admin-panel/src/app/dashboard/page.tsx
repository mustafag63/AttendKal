'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Users, BookOpen, CheckCircle, TrendingUp } from 'lucide-react';

// Mock data - TODO: Replace with real API calls
const mockStats = {
    totalUsers: 142,
    totalCourses: 12,
    attendanceRate: 89.5,
    weeklyGrowth: 12.5,
};

export default function DashboardPage() {
    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
                <p className="text-gray-600">Welcome back! Here&apos;s an overview of your system.</p>
            </div>

            {/* KPI Cards */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Users</CardTitle>
                        <Users className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.totalUsers}</div>
                        <p className="text-xs text-muted-foreground">
                            +12% from last month
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Courses</CardTitle>
                        <BookOpen className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.totalCourses}</div>
                        <p className="text-xs text-muted-foreground">
                            +2 this semester
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Attendance Rate</CardTitle>
                        <CheckCircle className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{mockStats.attendanceRate}%</div>
                        <p className="text-xs text-muted-foreground">
                            This week average
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Weekly Growth</CardTitle>
                        <TrendingUp className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">+{mockStats.weeklyGrowth}%</div>
                        <p className="text-xs text-muted-foreground">
                            Compared to last week
                        </p>
                    </CardContent>
                </Card>
            </div>

            {/* Recent Activity */}
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle>Recent Activity</CardTitle>
                        <CardDescription>Latest updates from your system</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="flex items-center space-x-4">
                                <div className="w-2 h-2 bg-green-500 rounded-full" />
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium text-gray-900">
                                        New user registered
                                    </p>
                                    <p className="text-sm text-gray-500">john.doe@email.com</p>
                                </div>
                                <div className="text-sm text-gray-500">2 min ago</div>
                            </div>

                            <div className="flex items-center space-x-4">
                                <div className="w-2 h-2 bg-blue-500 rounded-full" />
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium text-gray-900">
                                        Course updated
                                    </p>
                                    <p className="text-sm text-gray-500">Mathematics 101</p>
                                </div>
                                <div className="text-sm text-gray-500">1 hour ago</div>
                            </div>

                            <div className="flex items-center space-x-4">
                                <div className="w-2 h-2 bg-yellow-500 rounded-full" />
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium text-gray-900">
                                        Attendance marked
                                    </p>
                                    <p className="text-sm text-gray-500">Physics Lab session</p>
                                </div>
                                <div className="text-sm text-gray-500">3 hours ago</div>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle>Quick Actions</CardTitle>
                        <CardDescription>Common tasks you might want to perform</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            <button className="w-full text-left px-4 py-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                                <p className="font-medium">Add New User</p>
                                <p className="text-sm text-gray-500">Create a new user account</p>
                            </button>

                            <button className="w-full text-left px-4 py-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                                <p className="font-medium">Create Course</p>
                                <p className="text-sm text-gray-500">Add a new course to the system</p>
                            </button>

                            <button className="w-full text-left px-4 py-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors">
                                <p className="font-medium">Mark Attendance</p>
                                <p className="text-sm text-gray-500">Record student attendance</p>
                            </button>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
} 