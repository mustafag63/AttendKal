'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { DataTable } from '@/components/data-table/data-table';
import {
    Calendar,
    CheckCircle,
    XCircle,
    Clock,
    Search,
    Filter,
    Download,
    Eye,
    Edit,
    Trash2,
    Plus
} from 'lucide-react';

// Mock data - TODO: Replace with real API calls
const mockAttendance = [
    {
        id: '1',
        studentName: 'John Doe',
        studentEmail: 'john.doe@email.com',
        courseName: 'Mathematics 101',
        courseCode: 'MATH101',
        date: '2025-01-08',
        status: 'present',
        checkInTime: '09:15',
        location: 'Room A-101',
    },
    {
        id: '2',
        studentName: 'Jane Smith',
        studentEmail: 'jane.smith@email.com',
        courseName: 'Physics Lab',
        courseCode: 'PHYS201',
        date: '2025-01-08',
        status: 'late',
        checkInTime: '09:25',
        location: 'Lab B-203',
    },
    {
        id: '3',
        studentName: 'Bob Johnson',
        studentEmail: 'bob.johnson@email.com',
        courseName: 'Chemistry',
        courseCode: 'CHEM101',
        date: '2025-01-07',
        status: 'absent',
        checkInTime: null,
        location: 'Room C-105',
    },
];

const getStatusBadge = (status: string) => {
    switch (status) {
        case 'present':
            return <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50">
                <CheckCircle className="w-3 h-3 mr-1" />
                Present
            </Badge>;
        case 'late':
            return <Badge variant="outline" className="text-yellow-700 border-yellow-300 bg-yellow-50">
                <Clock className="w-3 h-3 mr-1" />
                Late
            </Badge>;
        case 'absent':
            return <Badge variant="outline" className="text-red-700 border-red-300 bg-red-50">
                <XCircle className="w-3 h-3 mr-1" />
                Absent
            </Badge>;
        default:
            return <Badge variant="outline">{status}</Badge>;
    }
};

const columns = [
    {
        accessorKey: 'studentName',
        header: 'Student',
        cell: ({ row }: any) => (
            <div>
                <div className="font-medium">{row.original.studentName}</div>
                <div className="text-sm text-gray-500">{row.original.studentEmail}</div>
            </div>
        ),
    },
    {
        accessorKey: 'courseName',
        header: 'Course',
        cell: ({ row }: any) => (
            <div>
                <div className="font-medium">{row.original.courseName}</div>
                <div className="text-sm text-gray-500">{row.original.courseCode}</div>
            </div>
        ),
    },
    {
        accessorKey: 'date',
        header: 'Date',
    },
    {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }: any) => getStatusBadge(row.original.status),
    },
    {
        accessorKey: 'checkInTime',
        header: 'Check-in Time',
        cell: ({ row }: any) => row.original.checkInTime || '-',
    },
    {
        accessorKey: 'location',
        header: 'Location',
    },
    {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }: any) => (
            <div className="flex space-x-2">
                <Button variant="ghost" size="sm">
                    <Eye className="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="sm">
                    <Edit className="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
                    <Trash2 className="w-4 h-4" />
                </Button>
            </div>
        ),
    },
];

export default function AttendancePage() {
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [dateFilter, setDateFilter] = useState('');

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Attendance Management</h1>
                    <p className="text-gray-600">Monitor and manage student attendance</p>
                </div>
                <div className="flex space-x-3">
                    <Button variant="outline">
                        <Download className="w-4 h-4 mr-2" />
                        Export
                    </Button>
                    <Button>
                        <Plus className="w-4 h-4 mr-2" />
                        Mark Attendance
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid gap-6 md:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Today's Present</CardTitle>
                        <CheckCircle className="h-4 w-4 text-green-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-600">87</div>
                        <p className="text-xs text-muted-foreground">
                            89.2% attendance rate
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Today's Late</CardTitle>
                        <Clock className="h-4 w-4 text-yellow-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-yellow-600">8</div>
                        <p className="text-xs text-muted-foreground">
                            8.2% late arrivals
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Today's Absent</CardTitle>
                        <XCircle className="h-4 w-4 text-red-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-red-600">3</div>
                        <p className="text-xs text-muted-foreground">
                            2.6% absent rate
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Weekly Average</CardTitle>
                        <Calendar className="h-4 w-4 text-blue-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-blue-600">91.5%</div>
                        <p className="text-xs text-muted-foreground">
                            +2.1% from last week
                        </p>
                    </CardContent>
                </Card>
            </div>

            {/* Filters */}
            <Card>
                <CardHeader>
                    <CardTitle>Filters</CardTitle>
                    <CardDescription>Filter attendance records by various criteria</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-4 md:grid-cols-4">
                        <div className="space-y-2">
                            <Label htmlFor="search">Search Student/Course</Label>
                            <div className="relative">
                                <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                                <Input
                                    id="search"
                                    placeholder="Search..."
                                    className="pl-10"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="status">Status</Label>
                            <Select value={statusFilter} onValueChange={setStatusFilter}>
                                <SelectTrigger>
                                    <SelectValue placeholder="All Status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">All Status</SelectItem>
                                    <SelectItem value="present">Present</SelectItem>
                                    <SelectItem value="late">Late</SelectItem>
                                    <SelectItem value="absent">Absent</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="date">Date</Label>
                            <Input
                                id="date"
                                type="date"
                                value={dateFilter}
                                onChange={(e) => setDateFilter(e.target.value)}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label>&nbsp;</Label>
                            <Button variant="outline" className="w-full">
                                <Filter className="w-4 h-4 mr-2" />
                                Reset Filters
                            </Button>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Data Table */}
            <Card>
                <CardHeader>
                    <CardTitle>Attendance Records</CardTitle>
                    <CardDescription>
                        Manage all attendance records with comprehensive controls
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <DataTable columns={columns} data={mockAttendance} />
                </CardContent>
            </Card>
        </div>
    );
} 