'use client';

import { useState, useMemo } from 'react';
import { ColumnDef } from '@tanstack/react-table';
import { MoreHorizontal, Plus, Edit, Trash2, Clock } from 'lucide-react';
import { format } from 'date-fns';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { DataTable } from '@/components/data-table/data-table';
import { CourseFormDialog } from '@/components/forms/course-form-dialog';
import { Course } from '@/lib/zod-schemas';
import { useCourses, useDeleteCourse } from '@/hooks/useCourses';

const formatDay = (day: string) => {
    return day.charAt(0).toUpperCase() + day.slice(1);
};

const formatTimeRange = (start: string, end: string) => {
    return `${start} - ${end}`;
};

export default function CoursesPage() {
    const [page, setPage] = useState(0);
    const [pageSize, setPageSize] = useState(10);
    const [search, setSearch] = useState('');
    const [formDialog, setFormDialog] = useState<{
        open: boolean;
        mode: 'create' | 'edit';
        course?: Course;
    }>({
        open: false,
        mode: 'create',
    });
    const [deleteDialog, setDeleteDialog] = useState<{
        open: boolean;
        course?: Course;
    }>({
        open: false,
    });

    const { data, isLoading } = useCourses({
        page: page + 1, // API expects 1-based indexing
        limit: pageSize,
        search: search || undefined,
    });

    const deleteCourse = useDeleteCourse();

    const columns: ColumnDef<Course>[] = useMemo(
        () => [
            {
                accessorKey: 'code',
                header: 'Course Code',
                cell: ({ row }) => (
                    <div className="font-mono font-medium">{row.getValue('code')}</div>
                ),
            },
            {
                accessorKey: 'name',
                header: 'Course Name',
                cell: ({ row }) => (
                    <div className="font-medium">{row.getValue('name')}</div>
                ),
            },
            {
                accessorKey: 'day',
                header: 'Day',
                cell: ({ row }) => {
                    const day = row.getValue('day') as string;
                    return (
                        <Badge variant="outline">
                            {formatDay(day)}
                        </Badge>
                    );
                },
            },
            {
                id: 'schedule',
                header: 'Schedule',
                cell: ({ row }) => {
                    const start = row.original.start;
                    const end = row.original.end;
                    return (
                        <div className="flex items-center space-x-2">
                            <Clock className="h-4 w-4 text-muted-foreground" />
                            <span className="text-sm">{formatTimeRange(start, end)}</span>
                        </div>
                    );
                },
            },
            {
                accessorKey: 'createdAt',
                header: 'Created',
                cell: ({ row }) => {
                    const date = row.getValue('createdAt') as string;
                    return date ? format(new Date(date), 'MMM dd, yyyy') : '-';
                },
            },
            {
                id: 'actions',
                header: 'Actions',
                cell: ({ row }) => {
                    const course = row.original;

                    return (
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="ghost" className="h-8 w-8 p-0">
                                    <span className="sr-only">Open menu</span>
                                    <MoreHorizontal className="h-4 w-4" />
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                                <DropdownMenuLabel>Actions</DropdownMenuLabel>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem
                                    onClick={() =>
                                        setFormDialog({
                                            open: true,
                                            mode: 'edit',
                                            course,
                                        })
                                    }
                                >
                                    <Edit className="mr-2 h-4 w-4" />
                                    Edit
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                    onClick={() =>
                                        setDeleteDialog({
                                            open: true,
                                            course,
                                        })
                                    }
                                    className="text-red-600"
                                >
                                    <Trash2 className="mr-2 h-4 w-4" />
                                    Delete
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    );
                },
            },
        ],
        []
    );

    const handlePaginationChange = (newPage: number, newPageSize: number) => {
        setPage(newPage);
        setPageSize(newPageSize);
    };

    const handleSearchChange = (newSearch: string) => {
        setSearch(newSearch);
        setPage(0); // Reset to first page when searching
    };

    const handleDelete = async () => {
        if (deleteDialog.course?.id) {
            try {
                await deleteCourse.mutateAsync(deleteDialog.course.id);
                setDeleteDialog({ open: false });
            } catch {
                // Error handling is done in the mutation hook
            }
        }
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Courses</h1>
                    <p className="text-gray-600">Manage courses and their schedules</p>
                </div>
                <Button
                    onClick={() =>
                        setFormDialog({
                            open: true,
                            mode: 'create',
                        })
                    }
                >
                    <Plus className="mr-2 h-4 w-4" />
                    Add Course
                </Button>
            </div>

            {/* Data Table */}
            <DataTable
                columns={columns}
                data={data?.courses || []}
                pageCount={data?.totalPages}
                pageIndex={page}
                pageSize={pageSize}
                onPaginationChange={handlePaginationChange}
                onSearchChange={handleSearchChange}
                searchPlaceholder="Search courses..."
                isLoading={isLoading}
            />

            {/* Form Dialog */}
            <CourseFormDialog
                open={formDialog.open}
                onOpenChange={(open) =>
                    setFormDialog((prev) => ({ ...prev, open }))
                }
                mode={formDialog.mode}
                course={formDialog.course}
            />

            {/* Delete Confirmation Dialog */}
            <AlertDialog
                open={deleteDialog.open}
                onOpenChange={(open) => setDeleteDialog((prev) => ({ ...prev, open }))}
            >
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                        <AlertDialogDescription>
                            This action cannot be undone. This will permanently delete the course{' '}
                            <strong>{deleteDialog.course?.name}</strong> ({deleteDialog.course?.code}) and remove all associated
                            attendance records from the system.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDelete}
                            className="bg-red-600 hover:bg-red-700"
                            disabled={deleteCourse.isPending}
                        >
                            {deleteCourse.isPending ? 'Deleting...' : 'Delete'}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    );
} 