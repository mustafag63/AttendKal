'use client';

import { useState, useMemo } from 'react';
import { ColumnDef } from '@tanstack/react-table';
import { MoreHorizontal, Plus, Edit, Trash2 } from 'lucide-react';
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
import { UserFormDialog } from '@/components/forms/user-form-dialog';
import { User } from '@/lib/zod-schemas';
import { useUsers, useDeleteUser } from '@/hooks/useUsers';

export default function UsersPage() {
    const [page, setPage] = useState(0);
    const [pageSize, setPageSize] = useState(10);
    const [search, setSearch] = useState('');
    const [formDialog, setFormDialog] = useState<{
        open: boolean;
        mode: 'create' | 'edit';
        user?: User;
    }>({
        open: false,
        mode: 'create',
    });
    const [deleteDialog, setDeleteDialog] = useState<{
        open: boolean;
        user?: User;
    }>({
        open: false,
    });

    const { data, isLoading } = useUsers({
        page: page + 1, // API expects 1-based indexing
        limit: pageSize,
        search: search || undefined,
    });

    const deleteUser = useDeleteUser();

    const columns: ColumnDef<User>[] = useMemo(
        () => [
            {
                accessorKey: 'name',
                header: 'Name',
                cell: ({ row }) => (
                    <div className="font-medium">{row.getValue('name')}</div>
                ),
            },
            {
                accessorKey: 'email',
                header: 'Email',
            },
            {
                accessorKey: 'role',
                header: 'Role',
                cell: ({ row }) => {
                    const role = row.getValue('role') as string;
                    return (
                        <Badge variant={role === 'admin' ? 'default' : 'secondary'}>
                            {role}
                        </Badge>
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
                    const user = row.original;

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
                                            user,
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
                                            user,
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
        if (deleteDialog.user?.id) {
            try {
                await deleteUser.mutateAsync(deleteDialog.user.id);
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
                    <h1 className="text-3xl font-bold text-gray-900">Users</h1>
                    <p className="text-gray-600">Manage system users and their permissions</p>
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
                    Add User
                </Button>
            </div>

            {/* Data Table */}
            <DataTable
                columns={columns}
                data={data?.users || []}
                pageCount={data?.totalPages}
                pageIndex={page}
                pageSize={pageSize}
                onPaginationChange={handlePaginationChange}
                onSearchChange={handleSearchChange}
                searchPlaceholder="Search users..."
                isLoading={isLoading}
            />

            {/* Form Dialog */}
            <UserFormDialog
                open={formDialog.open}
                onOpenChange={(open) =>
                    setFormDialog((prev) => ({ ...prev, open }))
                }
                mode={formDialog.mode}
                user={formDialog.user}
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
                            This action cannot be undone. This will permanently delete the user{' '}
                            <strong>{deleteDialog.user?.name}</strong> and remove all their data
                            from the system.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={handleDelete}
                            className="bg-red-600 hover:bg-red-700"
                            disabled={deleteUser.isPending}
                        >
                            {deleteUser.isPending ? 'Deleting...' : 'Delete'}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    );
} 