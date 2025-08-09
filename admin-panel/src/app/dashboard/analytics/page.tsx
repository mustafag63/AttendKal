'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import {
    TrendingUp,
    TrendingDown,
    Users,
    BookOpen,
    Calendar,
    Download,
    BarChart3,
    PieChart,
    Activity,
    Target
} from 'lucide-react';

// Mock data for charts - TODO: Replace with real API calls
const attendanceData = [
    { name: 'Mon', present: 85, absent: 15 },
    { name: 'Tue', present: 92, absent: 8 },
    { name: 'Wed', present: 78, absent: 22 },
    { name: 'Thu', present: 88, absent: 12 },
    { name: 'Fri', present: 95, absent: 5 },
];

const coursePerformance = [
    { course: 'Mathematics 101', attendance: 92.5, students: 45 },
    { course: 'Physics Lab', attendance: 87.3, students: 32 },
    { course: 'Chemistry', attendance: 94.1, students: 38 },
    { course: 'Biology', attendance: 89.7, students: 41 },
    { course: 'Computer Science', attendance: 96.2, students: 28 },
];

const monthlyTrends = [
    { month: 'Sep', attendance: 88.2, courses: 12, students: 184 },
    { month: 'Oct', attendance: 90.1, courses: 12, students: 189 },
    { month: 'Nov', attendance: 87.5, courses: 13, students: 195 },
    { month: 'Dec', attendance: 91.3, courses: 13, students: 198 },
    { month: 'Jan', attendance: 89.7, courses: 14, students: 201 },
];

export default function AnalyticsPage() {
    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Analytics & Reports</h1>
                    <p className="text-gray-600">Comprehensive insights and performance metrics</p>
                </div>
                <div className="flex space-x-3">
                    <Select defaultValue="thisMonth">
                        <SelectTrigger className="w-40">
                            <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="thisWeek">This Week</SelectItem>
                            <SelectItem value="thisMonth">This Month</SelectItem>
                            <SelectItem value="thisQuarter">This Quarter</SelectItem>
                            <SelectItem value="thisYear">This Year</SelectItem>
                        </SelectContent>
                    </Select>
                    <Button variant="outline">
                        <Download className="w-4 h-4 mr-2" />
                        Export Report
                    </Button>
                </div>
            </div>

            {/* Key Metrics */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Overall Attendance</CardTitle>
                        <TrendingUp className="h-4 w-4 text-green-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">89.7%</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +2.1% from last month
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Students</CardTitle>
                        <Users className="h-4 w-4 text-blue-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">201</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +6 new this month
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Courses</CardTitle>
                        <BookOpen className="h-4 w-4 text-purple-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">14</div>
                        <div className="flex items-center text-xs text-green-600">
                            <TrendingUp className="w-3 h-3 mr-1" />
                            +1 new course
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Avg. Daily Sessions</CardTitle>
                        <Activity className="h-4 w-4 text-orange-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">24</div>
                        <div className="flex items-center text-xs text-red-600">
                            <TrendingDown className="w-3 h-3 mr-1" />
                            -1.2% from last week
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Charts Row */}
            <div className="grid gap-6 md:grid-cols-2">
                {/* Weekly Attendance Trend */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <BarChart3 className="w-5 h-5 mr-2" />
                            Weekly Attendance Trend
                        </CardTitle>
                        <CardDescription>
                            Attendance patterns throughout the week
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {attendanceData.map((day) => (
                                <div key={day.name} className="space-y-2">
                                    <div className="flex justify-between text-sm">
                                        <span className="font-medium">{day.name}</span>
                                        <span className="text-gray-500">{day.present}% present</span>
                                    </div>
                                    <div className="w-full bg-gray-200 rounded-full h-2">
                                        <div
                                            className="bg-green-600 h-2 rounded-full"
                                            style={{ width: `${day.present}%` }}
                                        />
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>

                {/* Course Performance */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Target className="w-5 h-5 mr-2" />
                            Course Performance
                        </CardTitle>
                        <CardDescription>
                            Attendance rates by course
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {coursePerformance.map((course) => (
                                <div key={course.course} className="space-y-2">
                                    <div className="flex justify-between text-sm">
                                        <span className="font-medium">{course.course}</span>
                                        <span className="text-gray-500">{course.attendance}%</span>
                                    </div>
                                    <div className="w-full bg-gray-200 rounded-full h-2">
                                        <div
                                            className={`h-2 rounded-full ${course.attendance >= 95 ? 'bg-green-600' :
                                                    course.attendance >= 90 ? 'bg-blue-600' :
                                                        course.attendance >= 85 ? 'bg-yellow-600' : 'bg-red-600'
                                                }`}
                                            style={{ width: `${course.attendance}%` }}
                                        />
                                    </div>
                                    <div className="text-xs text-gray-500">
                                        {course.students} students enrolled
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Monthly Trends */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Calendar className="w-5 h-5 mr-2" />
                        Monthly Trends
                    </CardTitle>
                    <CardDescription>
                        Key metrics over the past 5 months
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="border-b">
                                    <th className="text-left py-2">Month</th>
                                    <th className="text-right py-2">Attendance Rate</th>
                                    <th className="text-right py-2">Active Courses</th>
                                    <th className="text-right py-2">Total Students</th>
                                    <th className="text-right py-2">Trend</th>
                                </tr>
                            </thead>
                            <tbody>
                                {monthlyTrends.map((month, index) => {
                                    const prevMonth = monthlyTrends[index - 1];
                                    const trend = prevMonth ?
                                        month.attendance - prevMonth.attendance : 0;

                                    return (
                                        <tr key={month.month} className="border-b">
                                            <td className="py-3 font-medium">{month.month} 2025</td>
                                            <td className="text-right py-3">{month.attendance}%</td>
                                            <td className="text-right py-3">{month.courses}</td>
                                            <td className="text-right py-3">{month.students}</td>
                                            <td className="text-right py-3">
                                                {trend > 0 ? (
                                                    <span className="text-green-600 flex items-center justify-end">
                                                        <TrendingUp className="w-3 h-3 mr-1" />
                                                        +{trend.toFixed(1)}%
                                                    </span>
                                                ) : trend < 0 ? (
                                                    <span className="text-red-600 flex items-center justify-end">
                                                        <TrendingDown className="w-3 h-3 mr-1" />
                                                        {trend.toFixed(1)}%
                                                    </span>
                                                ) : (
                                                    <span className="text-gray-500">-</span>
                                                )}
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>

            {/* Insights & Recommendations */}
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="text-green-700">📈 Key Insights</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3 text-sm">
                            <div className="p-3 bg-green-50 rounded-lg">
                                <strong>Friday Peak:</strong> Highest attendance rates occur on Fridays (95%),
                                suggesting students are more motivated toward the weekend.
                            </div>
                            <div className="p-3 bg-blue-50 rounded-lg">
                                <strong>CS Excellence:</strong> Computer Science course maintains 96.2% attendance,
                                indicating high student engagement.
                            </div>
                            <div className="p-3 bg-purple-50 rounded-lg">
                                <strong>Growth Trend:</strong> Student enrollment increased by 9.2% over 5 months,
                                showing growing popularity.
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="text-orange-700">💡 Recommendations</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3 text-sm">
                            <div className="p-3 bg-orange-50 rounded-lg">
                                <strong>Wednesday Focus:</strong> Implement engagement strategies for Wednesdays
                                to improve the 78% attendance rate.
                            </div>
                            <div className="p-3 bg-yellow-50 rounded-lg">
                                <strong>Course Capacity:</strong> Consider expanding Computer Science course capacity
                                due to high demand and excellent attendance.
                            </div>
                            <div className="p-3 bg-red-50 rounded-lg">
                                <strong>Early Intervention:</strong> Monitor Physics Lab attendance patterns
                                and provide additional support to maintain engagement.
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
} 