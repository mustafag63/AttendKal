'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Switch } from '@/components/ui/switch';
import { DataTable } from '@/components/data-table/data-table';
import {
    Shield,
    AlertTriangle,
    Lock,
    Eye,
    Users,
    Activity,
    Monitor,
    Key,
    Ban,
    CheckCircle,
    XCircle,
    Globe,
    Clock,
    Smartphone,
    MapPin,
    RefreshCw
} from 'lucide-react';

// Mock security data - TODO: Replace with real API calls
const securitySettings = {
    twoFactorEnabled: true,
    sessionTimeout: 30,
    maxLoginAttempts: 5,
    passwordExpiry: 90,
    ipWhitelistEnabled: false,
    auditLogging: true,
};

const activeSessions = [
    {
        id: '1',
        user: 'Admin User',
        email: 'admin@attendkal.com',
        device: 'Chrome on MacOS',
        location: 'Istanbul, Turkey',
        ip: '192.168.1.100',
        loginTime: '2025-01-08 20:30:00',
        lastActivity: '2 minutes ago',
        status: 'active',
    },
    {
        id: '2',
        user: 'John Doe',
        email: 'john.doe@email.com',
        device: 'Safari on iPhone',
        location: 'Ankara, Turkey',
        ip: '10.0.0.45',
        loginTime: '2025-01-08 18:45:00',
        lastActivity: '15 minutes ago',
        status: 'active',
    },
    {
        id: '3',
        user: 'Jane Smith',
        email: 'jane.smith@email.com',
        device: 'Edge on Windows',
        location: 'Izmir, Turkey',
        ip: '172.16.0.89',
        loginTime: '2025-01-08 16:20:00',
        lastActivity: '1 hour ago',
        status: 'idle',
    },
];

const securityLogs = [
    {
        id: '1',
        timestamp: '2025-01-08 20:45:00',
        type: 'authentication',
        severity: 'info',
        user: 'admin@attendkal.com',
        action: 'Successful Login',
        ip: '192.168.1.100',
        details: 'User logged in successfully',
    },
    {
        id: '2',
        timestamp: '2025-01-08 20:30:00',
        type: 'security',
        severity: 'warning',
        user: 'unknown@hacker.com',
        action: 'Failed Login Attempt',
        ip: '45.123.45.67',
        details: 'Multiple failed login attempts detected',
    },
    {
        id: '3',
        timestamp: '2025-01-08 19:15:00',
        type: 'authorization',
        severity: 'error',
        user: 'john.doe@email.com',
        action: 'Unauthorized Access',
        ip: '10.0.0.45',
        details: 'Attempted to access admin panel without permissions',
    },
];

const threatDetection = {
    totalThreats: 23,
    blockedIPs: 8,
    failedLogins: 45,
    suspiciousActivity: 12,
};

const getSeverityBadge = (severity: string) => {
    switch (severity) {
        case 'info':
            return <Badge variant="outline" className="text-blue-700 border-blue-300 bg-blue-50">Info</Badge>;
        case 'warning':
            return <Badge variant="outline" className="text-yellow-700 border-yellow-300 bg-yellow-50">Warning</Badge>;
        case 'error':
            return <Badge variant="outline" className="text-red-700 border-red-300 bg-red-50">Error</Badge>;
        default:
            return <Badge variant="outline">{severity}</Badge>;
    }
};

const getStatusBadge = (status: string) => {
    switch (status) {
        case 'active':
            return <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50">
                <CheckCircle className="w-3 h-3 mr-1" />
                Active
            </Badge>;
        case 'idle':
            return <Badge variant="outline" className="text-yellow-700 border-yellow-300 bg-yellow-50">
                <Clock className="w-3 h-3 mr-1" />
                Idle
            </Badge>;
        case 'blocked':
            return <Badge variant="outline" className="text-red-700 border-red-300 bg-red-50">
                <Ban className="w-3 h-3 mr-1" />
                Blocked
            </Badge>;
        default:
            return <Badge variant="outline">{status}</Badge>;
    }
};

const sessionColumns = [
    {
        accessorKey: 'user',
        header: 'User',
        cell: ({ row }: any) => (
            <div>
                <div className="font-medium">{row.original.user}</div>
                <div className="text-sm text-gray-500">{row.original.email}</div>
            </div>
        ),
    },
    {
        accessorKey: 'device',
        header: 'Device',
        cell: ({ row }: any) => (
            <div className="flex items-center">
                <Smartphone className="w-4 h-4 mr-2 text-gray-400" />
                {row.original.device}
            </div>
        ),
    },
    {
        accessorKey: 'location',
        header: 'Location',
        cell: ({ row }: any) => (
            <div className="flex items-center">
                <MapPin className="w-4 h-4 mr-2 text-gray-400" />
                <div>
                    <div className="text-sm">{row.original.location}</div>
                    <div className="text-xs text-gray-500">{row.original.ip}</div>
                </div>
            </div>
        ),
    },
    {
        accessorKey: 'loginTime',
        header: 'Login Time',
    },
    {
        accessorKey: 'lastActivity',
        header: 'Last Activity',
    },
    {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ row }: any) => getStatusBadge(row.original.status),
    },
    {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }: any) => (
            <div className="flex space-x-2">
                <Button variant="ghost" size="sm">
                    <Eye className="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
                    <Ban className="w-4 h-4" />
                </Button>
            </div>
        ),
    },
];

const logColumns = [
    {
        accessorKey: 'timestamp',
        header: 'Timestamp',
    },
    {
        accessorKey: 'type',
        header: 'Type',
        cell: ({ row }: any) => (
            <Badge variant="outline" className="capitalize">
                {row.original.type}
            </Badge>
        ),
    },
    {
        accessorKey: 'severity',
        header: 'Severity',
        cell: ({ row }: any) => getSeverityBadge(row.original.severity),
    },
    {
        accessorKey: 'user',
        header: 'User',
    },
    {
        accessorKey: 'action',
        header: 'Action',
    },
    {
        accessorKey: 'ip',
        header: 'IP Address',
    },
    {
        accessorKey: 'details',
        header: 'Details',
        cell: ({ row }: any) => (
            <div className="max-w-xs truncate" title={row.original.details}>
                {row.original.details}
            </div>
        ),
    },
];

export default function SecurityPage() {
    const [settings, setSettings] = useState(securitySettings);

    const updateSetting = (key: string, value: any) => {
        setSettings(prev => ({ ...prev, [key]: value }));
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Security Management</h1>
                    <p className="text-gray-600">Monitor security threats, manage user sessions, and configure security settings</p>
                </div>
                <div className="flex space-x-3">
                    <Button variant="outline">
                        <RefreshCw className="w-4 h-4 mr-2" />
                        Refresh
                    </Button>
                    <Button variant="outline">
                        <Shield className="w-4 h-4 mr-2" />
                        Security Scan
                    </Button>
                </div>
            </div>

            {/* Security Overview */}
            <div className="grid gap-6 md:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Threats</CardTitle>
                        <AlertTriangle className="h-4 w-4 text-red-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-red-600">{threatDetection.totalThreats}</div>
                        <p className="text-xs text-muted-foreground">
                            Last 24 hours
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Blocked IPs</CardTitle>
                        <Ban className="h-4 w-4 text-orange-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-orange-600">{threatDetection.blockedIPs}</div>
                        <p className="text-xs text-muted-foreground">
                            Currently blocked
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Failed Logins</CardTitle>
                        <XCircle className="h-4 w-4 text-yellow-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-yellow-600">{threatDetection.failedLogins}</div>
                        <p className="text-xs text-muted-foreground">
                            Today
                        </p>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Sessions</CardTitle>
                        <Monitor className="h-4 w-4 text-green-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-600">{activeSessions.length}</div>
                        <p className="text-xs text-muted-foreground">
                            Currently online
                        </p>
                    </CardContent>
                </Card>
            </div>

            {/* Security Settings */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Lock className="w-5 h-5 mr-2" />
                        Security Settings
                    </CardTitle>
                    <CardDescription>
                        Configure security policies and authentication settings
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-6 md:grid-cols-2">
                        <div className="space-y-4">
                            <div className="flex items-center justify-between">
                                <div>
                                    <Label className="text-sm font-medium">Two-Factor Authentication</Label>
                                    <p className="text-xs text-gray-500">Require 2FA for all admin users</p>
                                </div>
                                <Switch
                                    checked={settings.twoFactorEnabled}
                                    onCheckedChange={(checked) => updateSetting('twoFactorEnabled', checked)}
                                />
                            </div>

                            <div className="flex items-center justify-between">
                                <div>
                                    <Label className="text-sm font-medium">IP Whitelist</Label>
                                    <p className="text-xs text-gray-500">Restrict access to specific IP addresses</p>
                                </div>
                                <Switch
                                    checked={settings.ipWhitelistEnabled}
                                    onCheckedChange={(checked) => updateSetting('ipWhitelistEnabled', checked)}
                                />
                            </div>

                            <div className="flex items-center justify-between">
                                <div>
                                    <Label className="text-sm font-medium">Audit Logging</Label>
                                    <p className="text-xs text-gray-500">Log all administrative actions</p>
                                </div>
                                <Switch
                                    checked={settings.auditLogging}
                                    onCheckedChange={(checked) => updateSetting('auditLogging', checked)}
                                />
                            </div>
                        </div>

                        <div className="space-y-4">
                            <div className="space-y-2">
                                <Label className="text-sm font-medium">Session Timeout (minutes)</Label>
                                <Input
                                    type="number"
                                    value={settings.sessionTimeout}
                                    onChange={(e) => updateSetting('sessionTimeout', parseInt(e.target.value))}
                                    className="w-24"
                                />
                            </div>

                            <div className="space-y-2">
                                <Label className="text-sm font-medium">Max Login Attempts</Label>
                                <Input
                                    type="number"
                                    value={settings.maxLoginAttempts}
                                    onChange={(e) => updateSetting('maxLoginAttempts', parseInt(e.target.value))}
                                    className="w-24"
                                />
                            </div>

                            <div className="space-y-2">
                                <Label className="text-sm font-medium">Password Expiry (days)</Label>
                                <Input
                                    type="number"
                                    value={settings.passwordExpiry}
                                    onChange={(e) => updateSetting('passwordExpiry', parseInt(e.target.value))}
                                    className="w-24"
                                />
                            </div>
                        </div>
                    </div>

                    <div className="pt-4">
                        <Button>
                            <Shield className="w-4 h-4 mr-2" />
                            Save Security Settings
                        </Button>
                    </div>
                </CardContent>
            </Card>

            {/* Active Sessions */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Users className="w-5 h-5 mr-2" />
                        Active User Sessions
                    </CardTitle>
                    <CardDescription>
                        Monitor and manage currently active user sessions
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <DataTable columns={sessionColumns} data={activeSessions} />
                </CardContent>
            </Card>

            {/* Security Logs */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Activity className="w-5 h-5 mr-2" />
                        Security Logs
                    </CardTitle>
                    <CardDescription>
                        Recent security events and authentication attempts
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <DataTable columns={logColumns} data={securityLogs} />
                </CardContent>
            </Card>

            {/* Security Alerts */}
            <div className="space-y-4">
                <Alert className="border-red-300 bg-red-50">
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                        <strong>High Priority:</strong> Multiple failed login attempts detected from IP 45.123.45.67.
                        Consider blocking this IP address.
                    </AlertDescription>
                </Alert>

                <Alert className="border-yellow-300 bg-yellow-50">
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                        <strong>Medium Priority:</strong> User john.doe@email.com attempted to access admin panel
                        without proper permissions. Account has been temporarily suspended.
                    </AlertDescription>
                </Alert>
            </div>
        </div>
    );
} 