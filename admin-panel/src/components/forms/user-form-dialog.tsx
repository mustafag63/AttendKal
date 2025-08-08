'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { CreateUserSchema, UpdateUserSchema, User, CreateUser, UpdateUser } from '@/lib/zod-schemas';
import { useCreateUser, useUpdateUser } from '@/hooks/useUsers';

interface UserFormDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    user?: User;
    mode: 'create' | 'edit';
}

export function UserFormDialog({
    open,
    onOpenChange,
    user,
    mode,
}: UserFormDialogProps) {
    const createUser = useCreateUser();
    const updateUser = useUpdateUser();

    const schema = mode === 'create' ? CreateUserSchema : UpdateUserSchema;

    const {
        register,
        handleSubmit,
        setValue,
        watch,
        reset,
        formState: { errors },
    } = useForm<CreateUser | UpdateUser>({
        resolver: zodResolver(schema),
        defaultValues: {
            name: '',
            email: '',
            password: '',
            role: 'user' as const,
        },
    });

    const role = watch('role');

    // Reset form when dialog opens/closes or user changes
    useEffect(() => {
        if (open) {
            if (mode === 'edit' && user) {
                setValue('name', user.name);
                setValue('email', user.email);
                setValue('role', user.role);
                // Don't set password for edit mode
            } else {
                reset({
                    name: '',
                    email: '',
                    password: '',
                    role: 'user',
                });
            }
        }
    }, [open, mode, user, setValue, reset]);

    const onSubmit = async (data: CreateUser | UpdateUser) => {
        try {
            if (mode === 'create') {
                await createUser.mutateAsync(data as CreateUser);
            } else if (mode === 'edit' && user) {
                await updateUser.mutateAsync({ id: user.id!, ...data } as UpdateUser & { id: string });
            }
            onOpenChange(false);
            reset();
        } catch {
            // Error handling is done in the mutation hooks
        }
    };

    const isLoading = createUser.isPending || updateUser.isPending;

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'create' ? 'Create User' : 'Edit User'}
                    </DialogTitle>
                    <DialogDescription>
                        {mode === 'create'
                            ? 'Add a new user to the system. All fields are required.'
                            : 'Update user information. Leave password empty to keep current password.'
                        }
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                    <div className="space-y-2">
                        <Label htmlFor="name">Name</Label>
                        <Input
                            id="name"
                            placeholder="John Doe"
                            {...register('name')}
                            className={errors.name ? 'border-red-500' : ''}
                        />
                        {errors.name && (
                            <p className="text-sm text-red-500">{errors.name.message}</p>
                        )}
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="email">Email</Label>
                        <Input
                            id="email"
                            type="email"
                            placeholder="john.doe@example.com"
                            {...register('email')}
                            className={errors.email ? 'border-red-500' : ''}
                        />
                        {errors.email && (
                            <p className="text-sm text-red-500">{errors.email.message}</p>
                        )}
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="password">
                            Password {mode === 'edit' && '(leave empty to keep current)'}
                        </Label>
                        <Input
                            id="password"
                            type="password"
                            placeholder={mode === 'create' ? 'Enter password' : 'Leave empty to keep current'}
                            {...register('password')}
                            className={errors.password ? 'border-red-500' : ''}
                        />
                        {errors.password && (
                            <p className="text-sm text-red-500">{errors.password.message}</p>
                        )}
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="role">Role</Label>
                        <Select
                            value={role}
                            onValueChange={(value) => setValue('role', value as 'admin' | 'user')}
                        >
                            <SelectTrigger className={errors.role ? 'border-red-500' : ''}>
                                <SelectValue placeholder="Select a role" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="user">User</SelectItem>
                                <SelectItem value="admin">Admin</SelectItem>
                            </SelectContent>
                        </Select>
                        {errors.role && (
                            <p className="text-sm text-red-500">{errors.role.message}</p>
                        )}
                    </div>

                    <DialogFooter>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => onOpenChange(false)}
                            disabled={isLoading}
                        >
                            Cancel
                        </Button>
                        <Button type="submit" disabled={isLoading}>
                            {isLoading ? 'Saving...' : mode === 'create' ? 'Create User' : 'Update User'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
} 