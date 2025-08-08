'use client';

import { Search, Bell, LogOut, User, Menu } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useMe, useLogout } from '@/hooks/useAuth';

interface TopbarProps {
    onMenuClick?: () => void;
}

export function Topbar({ onMenuClick }: TopbarProps) {
    const { data: user } = useMe();
    const logout = useLogout();

    const handleLogout = () => {
        logout.mutate();
    };

    return (
        <header className="h-16 bg-white border-b flex items-center justify-between px-6">
            {/* Left side */}
            <div className="flex items-center space-x-4">
                <Button
                    variant="ghost"
                    size="icon"
                    className="md:hidden"
                    onClick={onMenuClick}
                >
                    <Menu className="h-5 w-5" />
                </Button>

                <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                        placeholder="Search..."
                        className="pl-10 w-64 bg-gray-50 border-0"
                    />
                </div>
            </div>

            {/* Right side */}
            <div className="flex items-center space-x-4">
                {/* Notifications */}
                <Button variant="ghost" size="icon">
                    <Bell className="h-5 w-5" />
                </Button>

                {/* User menu */}
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="flex items-center space-x-2">
                            <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                                <User className="h-4 w-4 text-primary-foreground" />
                            </div>
                            <div className="hidden md:block text-left">
                                <p className="text-sm font-medium">{user?.name || 'Admin'}</p>
                                <p className="text-xs text-gray-500">{user?.email}</p>
                            </div>
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-56">
                        <DropdownMenuLabel>My Account</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem>
                            <User className="mr-2 h-4 w-4" />
                            <span>Profile</span>
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem onClick={handleLogout}>
                            <LogOut className="mr-2 h-4 w-4" />
                            <span>Log out</span>
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>
        </header>
    );
} 