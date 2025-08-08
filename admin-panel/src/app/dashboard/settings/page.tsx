'use client';

import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { useQueryClient } from '@tanstack/react-query';
import { useLogout, useMe } from '@/hooks/useAuth';
import { config } from '@/lib/config';
import { toast } from 'sonner';
import { Settings as SettingsIcon, Database, User, LogOut, Trash2 } from 'lucide-react';

export default function SettingsPage() {
    const { data: user } = useMe();
    const logout = useLogout();
    const queryClient = useQueryClient();

    const handleClearCache = () => {
        queryClient.clear();
        toast.success('Cache cleared successfully');
    };

    const handleLogout = () => {
        logout.mutate();
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center space-x-4">
                <SettingsIcon className="h-8 w-8 text-primary" />
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
                    <p className="text-gray-600">Manage system settings and preferences</p>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                {/* User Information */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center space-x-2">
                            <User className="h-5 w-5" />
                            <span>User Information</span>
                        </CardTitle>
                        <CardDescription>Your current user account details</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <label className="text-sm font-medium text-gray-500">Name</label>
                            <p className="text-lg font-medium">{user?.name || 'N/A'}</p>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-gray-500">Email</label>
                            <p className="text-lg">{user?.email || 'N/A'}</p>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-gray-500">Role</label>
                            <div className="mt-1">
                                <Badge variant={user?.role === 'admin' ? 'default' : 'secondary'}>
                                    {user?.role || 'Unknown'}
                                </Badge>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* API Configuration */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center space-x-2">
                            <Database className="h-5 w-5" />
                            <span>API Configuration</span>
                        </CardTitle>
                        <CardDescription>Current API endpoint configuration</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <label className="text-sm font-medium text-gray-500">Base URL</label>
                            <p className="text-lg font-mono bg-gray-100 p-2 rounded text-sm">
                                {config.apiBaseUrl}
                            </p>
                        </div>
                        <div>
                            <label className="text-sm font-medium text-gray-500">Status</label>
                            <div className="mt-1">
                                <Badge variant="outline" className="text-green-600">
                                    Connected
                                </Badge>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* System Actions */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center space-x-2">
                            <Trash2 className="h-5 w-5" />
                            <span>System Actions</span>
                        </CardTitle>
                        <CardDescription>Clear cache and manage system state</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-2">
                            <Button
                                variant="outline"
                                onClick={handleClearCache}
                                className="w-full"
                            >
                                Clear Cache
                            </Button>
                            <p className="text-xs text-gray-500">
                                Clear all cached data and force refresh from the server
                            </p>
                        </div>
                    </CardContent>
                </Card>

                {/* Session Management */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center space-x-2">
                            <LogOut className="h-5 w-5" />
                            <span>Session Management</span>
                        </CardTitle>
                        <CardDescription>Manage your current session</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-2">
                            <Button
                                variant="destructive"
                                onClick={handleLogout}
                                disabled={logout.isPending}
                                className="w-full"
                            >
                                {logout.isPending ? 'Logging out...' : 'Log Out'}
                            </Button>
                            <p className="text-xs text-gray-500">
                                End your current session and return to login
                            </p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Additional Information */}
            <Card>
                <CardHeader>
                    <CardTitle>System Information</CardTitle>
                    <CardDescription>Application and environment details</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                        <div>
                            <label className="font-medium text-gray-500">Application</label>
                            <p>AttendKal Admin Panel</p>
                        </div>
                        <div>
                            <label className="font-medium text-gray-500">Version</label>
                            <p>1.0.0</p>
                        </div>
                        <div>
                            <label className="font-medium text-gray-500">Environment</label>
                            <p>Development</p>
                        </div>
                        <div>
                            <label className="font-medium text-gray-500">Framework</label>
                            <p>Next.js 15</p>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
} 