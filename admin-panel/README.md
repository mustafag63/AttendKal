# AttendKal Admin Panel

A production-ready admin panel for managing courses, users, and attendance built with Next.js 14, TypeScript, and modern web technologies.

## 🚀 Features

### Authentication & Authorization
- JWT-based authentication with automatic token refresh
- Role-based access control (admin only)
- Secure token storage with automatic logout on token expiry
- Protected routes with authentication guards

### User Management
- Complete CRUD operations for users
- Data grid with server-side pagination, sorting, and search
- Form validation with Zod schemas
- Role management (admin/user)
- Bulk delete operations

### Course Management
- Full CRUD operations for courses
- Course scheduling with day and time management
- Search and filter functionality
- Time format validation

### Dashboard
- KPI cards showing system statistics
- Recent activity feed
- Quick action shortcuts
- Modern, responsive design

### Settings
- API configuration viewer
- Cache management
- Session management
- System information display

## 🛠 Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **State Management**: React Query (TanStack Query)
- **HTTP Client**: Axios with interceptors
- **Forms**: React Hook Form + Zod validation
- **Data Tables**: TanStack Table
- **Icons**: Lucide React
- **Notifications**: Sonner

## 📋 Prerequisites

- Node.js 18.x or later
- npm or pnpm
- Backend API server (see API endpoints below)

## 🏃‍♂️ Quick Start

1. **Clone and install dependencies**
   ```bash
   cd AttendKal/admin-panel
   npm install
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```
   
   Update `.env.local`:
   ```
   NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   ```
   http://localhost:3001
   ```

## 📱 Demo Credentials

For testing purposes, you can use these demo credentials:
- **Email**: `admin@attendkal.com`
- **Password**: `admin123`

## 🔌 API Integration

The admin panel is designed to work with REST API endpoints. Here are the expected endpoints:

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `POST /api/auth/refresh` - Refresh access token (optional)

### Users
- `GET /api/users` - List users with pagination and search
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Courses
- `GET /api/courses` - List courses with pagination and search
- `POST /api/courses` - Create new course
- `PUT /api/courses/:id` - Update course
- `DELETE /api/courses/:id` - Delete course

### Attendance (Future Implementation)
- `GET /api/attendance` - List attendance records
- `POST /api/attendance` - Create/update attendance
- `DELETE /api/attendance/:id` - Delete attendance record

## 🏗 Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── dashboard/         # Protected dashboard pages
│   │   ├── users/        # User management
│   │   ├── courses/      # Course management
│   │   └── settings/     # Settings page
│   ├── login/            # Login page
│   └── layout.tsx        # Root layout
├── components/            # Reusable components
│   ├── ui/               # shadcn/ui components
│   ├── data-table/       # Data table components
│   └── forms/            # Form components
├── hooks/                # Custom React hooks
├── lib/                  # Utility libraries
│   ├── axios.ts          # HTTP client setup
│   ├── auth.ts           # Authentication utilities
│   ├── config.ts         # Configuration
│   └── zod-schemas.ts    # Validation schemas
└── types/                # TypeScript type definitions
```

## 🎨 UI Components

Built with shadcn/ui for consistent, accessible, and customizable components:

- **Data Tables**: Server-side pagination, sorting, filtering
- **Forms**: Validated forms with error handling
- **Dialogs**: Modal dialogs for CRUD operations
- **Navigation**: Responsive sidebar and top navigation
- **Notifications**: Toast notifications for user feedback

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Route Protection**: All dashboard routes protected by auth guards
- **Role-based Access**: Admin-only access to the admin panel
- **Token Refresh**: Automatic token refresh to maintain sessions
- **Secure Storage**: Tokens stored securely with automatic cleanup

## 📊 Data Management

- **React Query**: Efficient data fetching with caching
- **Optimistic Updates**: Immediate UI updates with rollback on error
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Loading indicators for better UX

## 🎯 Development

### Available Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript type checking
```

### Code Quality

- **TypeScript**: Strict type checking enabled
- **ESLint**: Code linting with Next.js recommended rules
- **Prettier**: Code formatting (configured via ESLint)

## 🚀 Deployment

### Build for Production

```bash
npm run build
```

### Environment Variables

Ensure the following environment variables are set in production:

```
NEXT_PUBLIC_API_BASE_URL=https://your-api-domain.com
```

### Deployment Platforms

This Next.js application can be deployed to:
- **Vercel** (recommended)
- **Netlify**
- **AWS Amplify**
- **Google Cloud Platform**
- **Traditional hosting** with Node.js support

## 🔧 Configuration

### API Base URL

Update the API base URL in `.env.local`:

```
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
```

### Customization

- **Colors**: Update Tailwind theme in `tailwind.config.ts`
- **Components**: Modify shadcn/ui components in `src/components/ui/`
- **Validation**: Update Zod schemas in `src/lib/zod-schemas.ts`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is part of the AttendKal system. See the main project for license information.

## 🆘 Support

For support and questions:
1. Check the documentation
2. Search existing issues
3. Create a new issue with detailed information

## 🔄 API Mock/Stubs

The application includes placeholder API calls that can be replaced with real endpoints. To test with mock data:

1. Update the API hooks in `src/hooks/` to return mock data
2. Comment out actual API calls in development
3. Use the React Query Devtools to inspect data flow

## ✅ Todo / Roadmap

- [ ] Attendance management module
- [ ] Dashboard charts and analytics
- [ ] CSV export functionality
- [ ] Bulk user import
- [ ] Email notifications
- [ ] Advanced filtering
- [ ] Print functionality
- [ ] Mobile app integration

---

Built with ❤️ using Next.js 14 and modern web technologies.
