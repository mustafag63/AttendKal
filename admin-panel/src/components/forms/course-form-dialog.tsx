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
import { CreateCourseSchema, UpdateCourseSchema, Course, CreateCourse, UpdateCourse } from '@/lib/zod-schemas';
import { useCreateCourse, useUpdateCourse } from '@/hooks/useCourses';

const daysOfWeek = [
    { value: 'monday', label: 'Monday' },
    { value: 'tuesday', label: 'Tuesday' },
    { value: 'wednesday', label: 'Wednesday' },
    { value: 'thursday', label: 'Thursday' },
    { value: 'friday', label: 'Friday' },
    { value: 'saturday', label: 'Saturday' },
    { value: 'sunday', label: 'Sunday' },
];

interface CourseFormDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    course?: Course;
    mode: 'create' | 'edit';
}

export function CourseFormDialog({
    open,
    onOpenChange,
    course,
    mode,
}: CourseFormDialogProps) {
    const createCourse = useCreateCourse();
    const updateCourse = useUpdateCourse();

    const schema = mode === 'create' ? CreateCourseSchema : UpdateCourseSchema;

    const {
        register,
        handleSubmit,
        setValue,
        watch,
        reset,
        formState: { errors },
    } = useForm<CreateCourse | UpdateCourse>({
        resolver: zodResolver(schema),
        defaultValues: {
            code: '',
            name: '',
            day: 'monday' as const,
            start: '',
            end: '',
        },
    });

    const day = watch('day');

    // Reset form when dialog opens/closes or course changes
    useEffect(() => {
        if (open) {
            if (mode === 'edit' && course) {
                setValue('code', course.code);
                setValue('name', course.name);
                setValue('day', course.day);
                setValue('start', course.start);
                setValue('end', course.end);
            } else {
                reset({
                    code: '',
                    name: '',
                    day: 'monday',
                    start: '',
                    end: '',
                });
            }
        }
    }, [open, mode, course, setValue, reset]);

    const onSubmit = async (data: CreateCourse | UpdateCourse) => {
        try {
            if (mode === 'create') {
                await createCourse.mutateAsync(data as CreateCourse);
            } else if (mode === 'edit' && course) {
                await updateCourse.mutateAsync({ id: course.id!, ...data } as UpdateCourse & { id: string });
            }
            onOpenChange(false);
            reset();
        } catch {
            // Error handling is done in the mutation hooks
        }
    };

    const isLoading = createCourse.isPending || updateCourse.isPending;

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>
                        {mode === 'create' ? 'Create Course' : 'Edit Course'}
                    </DialogTitle>
                    <DialogDescription>
                        {mode === 'create'
                            ? 'Add a new course to the system. All fields are required.'
                            : 'Update course information. All fields are required.'
                        }
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                    <div className="space-y-2">
                        <Label htmlFor="code">Course Code</Label>
                        <Input
                            id="code"
                            placeholder="MATH101"
                            {...register('code')}
                            className={errors.code ? 'border-red-500' : ''}
                        />
                        {errors.code && (
                            <p className="text-sm text-red-500">{errors.code.message}</p>
                        )}
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="name">Course Name</Label>
                        <Input
                            id="name"
                            placeholder="Introduction to Mathematics"
                            {...register('name')}
                            className={errors.name ? 'border-red-500' : ''}
                        />
                        {errors.name && (
                            <p className="text-sm text-red-500">{errors.name.message}</p>
                        )}
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="day">Day of Week</Label>
                        <Select
                            value={day}
                            onValueChange={(value) => setValue('day', value as Course['day'])}
                        >
                            <SelectTrigger className={errors.day ? 'border-red-500' : ''}>
                                <SelectValue placeholder="Select a day" />
                            </SelectTrigger>
                            <SelectContent>
                                {daysOfWeek.map((day) => (
                                    <SelectItem key={day.value} value={day.value}>
                                        {day.label}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                        {errors.day && (
                            <p className="text-sm text-red-500">{errors.day.message}</p>
                        )}
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="start">Start Time</Label>
                            <Input
                                id="start"
                                type="time"
                                placeholder="09:00"
                                {...register('start')}
                                className={errors.start ? 'border-red-500' : ''}
                            />
                            {errors.start && (
                                <p className="text-sm text-red-500">{errors.start.message}</p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="end">End Time</Label>
                            <Input
                                id="end"
                                type="time"
                                placeholder="10:30"
                                {...register('end')}
                                className={errors.end ? 'border-red-500' : ''}
                            />
                            {errors.end && (
                                <p className="text-sm text-red-500">{errors.end.message}</p>
                            )}
                        </div>
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
                            {isLoading ? 'Saving...' : mode === 'create' ? 'Create Course' : 'Update Course'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
} 