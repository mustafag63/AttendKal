'use client';

import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import {
    Database,
    Server,
    HardDrive,
    Cpu,
    MemoryStick,
    RefreshCw,
    AlertTriangle,
    CheckCircle,
    XCircle,
    Clock,
    Activity,
    Trash2,
    Download,
    Upload,
    Settings,
    Terminal
} from 'lucide-react';

// Mock system data - TODO: Replace with real API calls
const systemHealth = {
    status: 'healthy',
    uptime: '7 days, 14 hours',
    version: '1.2.3',
    lastUpdated: '2025-01-07 15:30:00',
};

const systemMetrics = [
    { name: 'CPU Usage', value: 23, unit: '%', status: 'good', icon: Cpu },
    { name: 'Memory Usage', value: 68, unit: '%', status: 'warning', icon: MemoryStick },
    { name: 'Disk Usage', value: 45, unit: '%', status: 'good', icon: HardDrive },
    { name: 'Active Connections', value: 142, unit: '', status: 'good', icon: Activity },
];

const databaseInfo = {
    size: '1.2 GB',
    tables: 15,
    records: 125340,
    lastBackup: '2025-01-08 02:00:00',
    connections: 8,
};

const cacheStatus = {
    redisConnected: true,
    hitRate: 89.5,
    memoryUsage: 156,
    keys: 2847,
};

const maintenanceTasks = [
    { id: 1, name: 'Database Cleanup', lastRun: '2025-01-07', nextRun: '2025-01-14', status: 'scheduled' },
    { id: 2, name: 'Log Rotation', lastRun: '2025-01-08', nextRun: '2025-01-15', status: 'completed' },
    { id: 3, name: 'Cache Optimization', lastRun: '2025-01-06', nextRun: '2025-01-13', status: 'pending' },
    { id: 4, name: 'Security Scan', lastRun: '2025-01-05', nextRun: '2025-01-12', status: 'running' },
];

const getStatusColor = (status: string) => {
    switch (status) {
        case 'good': return 'text-green-600';
        case 'warning': return 'text-yellow-600';
        case 'error': return 'text-red-600';
        default: return 'text-gray-600';
    }
};

const getStatusBadge = (status: string) => {
    switch (status) {
        case 'completed':
            return <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50">Completed</Badge>;
        case 'running':
            return <Badge variant="outline" className="text-blue-700 border-blue-300 bg-blue-50">Running</Badge>;
        case 'scheduled':
            return <Badge variant="outline" className="text-purple-700 border-purple-300 bg-purple-50">Scheduled</Badge>;
        case 'pending':
            return <Badge variant="outline" className="text-yellow-700 border-yellow-300 bg-yellow-50">Pending</Badge>;
        default:
            return <Badge variant="outline">{status}</Badge>;
    }
};

export default function SystemPage() {
    const [isMaintenanceMode, setIsMaintenanceMode] = useState(false);

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">System Management</h1>
                    <p className="text-gray-600">Monitor and manage system health, database, and maintenance</p>
                </div>
                <div className="flex space-x-3">
                    <Button
                        variant={isMaintenanceMode ? "destructive" : "outline"}
                        onClick={() => setIsMaintenanceMode(!isMaintenanceMode)}
                    >
                        <Settings className="w-4 h-4 mr-2" />
                        {isMaintenanceMode ? 'Exit Maintenance' : 'Maintenance Mode'}
                    </Button>
                    <Button variant="outline">
                        <RefreshCw className="w-4 h-4 mr-2" />
                        Refresh
                    </Button>
                </div>
            </div>

            {/* Maintenance Mode Alert */}
            {isMaintenanceMode && (
                <Alert className="border-orange-300 bg-orange-50">
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                        <strong>Maintenance Mode Active:</strong> The system is currently in maintenance mode.
                        Users may experience limited functionality.
                    </AlertDescription>
                </Alert>
            )}

            {/* System Health Overview */}
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Server className="w-5 h-5 mr-2" />
                            System Health
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            <div className="flex items-center justify-between">
                                <span className="text-sm font-medium">Status</span>
                                <div className="flex items-center">
                                    <CheckCircle className="w-4 h-4 text-green-600 mr-2" />
                                    <span className="text-green-600 font-medium">Healthy</span>
                                </div>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-sm font-medium">Uptime</span>
                                <span className="text-sm text-gray-600">{systemHealth.uptime}</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-sm font-medium">Version</span>
                                <span className="text-sm text-gray-600">v{systemHealth.version}</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <span className="text-sm font-medium">Last Updated</span>
                                <span className="text-sm text-gray-600">{systemHealth.lastUpdated}</span>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Activity className="w-5 h-5 mr-2" />
                            Quick Actions
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            <Button variant="outline" className="w-full justify-start">
                                <Database className="w-4 h-4 mr-2" />
                                Database Backup
                            </Button>
                            <Button variant="outline" className="w-full justify-start">
                                <RefreshCw className="w-4 h-4 mr-2" />
                                Clear Cache
                            </Button>
                            <Button variant="outline" className="w-full justify-start">
                                <Trash2 className="w-4 h-4 mr-2" />
                                Clean Logs
                            </Button>
                            <Button variant="outline" className="w-full justify-start">
                                <Terminal className="w-4 h-4 mr-2" />
                                System Diagnostics
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* System Metrics */}
            <Card>
                <CardHeader>
                    <CardTitle>System Metrics</CardTitle>
                    <CardDescription>Real-time system performance indicators</CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-6 md:grid-cols-4">
                        {systemMetrics.map((metric) => {
                            const Icon = metric.icon;
                            return (
                                <div key={metric.name} className="space-y-2">
                                    <div className="flex items-center justify-between">
                                        <div className="flex items-center">
                                            <Icon className="w-4 h-4 mr-2 text-gray-500" />
                                            <span className="text-sm font-medium">{metric.name}</span>
                                        </div>
                                        <span className={`text-sm font-bold ${getStatusColor(metric.status)}`}>
                                            {metric.value}{metric.unit}
                                        </span>
                                    </div>
                                    <div className="w-full bg-gray-200 rounded-full h-2">
                                        <div
                                            className={`h-2 rounded-full ${metric.status === 'good' ? 'bg-green-600' :
                                                    metric.status === 'warning' ? 'bg-yellow-600' : 'bg-red-600'
                                                }`}
                                            style={{ width: `${Math.min(metric.value, 100)}%` }}
                                        />
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </CardContent>
            </Card>

            {/* Database & Cache Info */}
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <Database className="w-5 h-5 mr-2" />
                            Database Information
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Database Size</span>
                                <span className="text-sm text-gray-600">{databaseInfo.size}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Tables</span>
                                <span className="text-sm text-gray-600">{databaseInfo.tables}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Total Records</span>
                                <span className="text-sm text-gray-600">{databaseInfo.records.toLocaleString()}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Active Connections</span>
                                <span className="text-sm text-gray-600">{databaseInfo.connections}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Last Backup</span>
                                <span className="text-sm text-gray-600">{databaseInfo.lastBackup}</span>
                            </div>
                            <div className="pt-2 space-y-2">
                                <Button variant="outline" size="sm" className="w-full">
                                    <Download className="w-4 h-4 mr-2" />
                                    Create Backup
                                </Button>
                                <Button variant="outline" size="sm" className="w-full">
                                    <Upload className="w-4 h-4 mr-2" />
                                    Restore Backup
                                </Button>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center">
                            <MemoryStick className="w-5 h-5 mr-2" />
                            Cache Status
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Redis Connection</span>
                                <div className="flex items-center">
                                    {cacheStatus.redisConnected ? (
                                        <CheckCircle className="w-4 h-4 text-green-600" />
                                    ) : (
                                        <XCircle className="w-4 h-4 text-red-600" />
                                    )}
                                </div>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Hit Rate</span>
                                <span className="text-sm text-gray-600">{cacheStatus.hitRate}%</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Memory Usage</span>
                                <span className="text-sm text-gray-600">{cacheStatus.memoryUsage} MB</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-sm font-medium">Total Keys</span>
                                <span className="text-sm text-gray-600">{cacheStatus.keys.toLocaleString()}</span>
                            </div>
                            <div className="pt-2 space-y-2">
                                <Button variant="outline" size="sm" className="w-full">
                                    <RefreshCw className="w-4 h-4 mr-2" />
                                    Flush Cache
                                </Button>
                                <Button variant="outline" size="sm" className="w-full">
                                    <Activity className="w-4 h-4 mr-2" />
                                    Cache Stats
                                </Button>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Maintenance Tasks */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center">
                        <Clock className="w-5 h-5 mr-2" />
                        Maintenance Tasks
                    </CardTitle>
                    <CardDescription>
                        Scheduled and completed maintenance operations
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="border-b">
                                    <th className="text-left py-2">Task</th>
                                    <th className="text-left py-2">Last Run</th>
                                    <th className="text-left py-2">Next Run</th>
                                    <th className="text-left py-2">Status</th>
                                    <th className="text-left py-2">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {maintenanceTasks.map((task) => (
                                    <tr key={task.id} className="border-b">
                                        <td className="py-3 font-medium">{task.name}</td>
                                        <td className="py-3 text-sm text-gray-600">{task.lastRun}</td>
                                        <td className="py-3 text-sm text-gray-600">{task.nextRun}</td>
                                        <td className="py-3">{getStatusBadge(task.status)}</td>
                                        <td className="py-3">
                                            <Button variant="ghost" size="sm">
                                                <RefreshCw className="w-4 h-4" />
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
} 