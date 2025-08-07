# 📚 AttendKal - Smart Student Attendance Tracking

A comprehensive student attendance tracking system built with **Flutter** and **Node.js Express**, featuring course management, real-time attendance tracking, and subscription-based features.

## 🏗️ Architecture

### Backend (Node.js Express)
- **Framework**: Express.js with modern ES6+ features
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT-based with refresh tokens
- **Security**: Comprehensive security middleware (Helmet, CORS, Rate Limiting)
- **Documentation**: Auto-generated Swagger/OpenAPI docs
- **Monitoring**: Prometheus metrics and Winston logging
- **Testing**: Jest with Supertest integration

### Frontend (Flutter)
- **Framework**: Flutter 3.24+ with Material Design 3
- **State Management**: BLoC pattern with flutter_bloc
- **Navigation**: Go Router for declarative routing
- **Networking**: Dio HTTP client with automatic retry
- **Storage**: Local SQLite with shared preferences
- **Notifications**: Local notifications (no Firebase dependency)

## ✨ Features

### 🔐 Authentication & Security
- **Secure JWT Authentication** with automatic token refresh
- **Role-based Access Control** (Student, Teacher, Admin)
- **Password encryption** with bcrypt
- **Session management** with device tracking
- **Rate limiting** and request validation

### 📚 Course Management
- **Create and manage courses** with scheduling
- **Color-coded course cards** for easy identification
- **Search and filter** functionality
- **Course statistics** and attendance tracking
- **Instructor and semester management**

### ✅ Attendance Tracking
- **Quick attendance marking** with multiple statuses
- **GPS location verification** (optional)
- **Attendance history** with visual analytics
- **Statistical reporting** and trend analysis
- **Bulk attendance management**

### 💎 Subscription System
- **Free Tier**: Up to 2 courses
- **Pro Tier**: Unlimited courses + advanced features
- **Premium Tier**: All features + priority support
- **Seamless upgrade process**

### 📊 Analytics & Reporting
- **Attendance rate calculations**
- **Visual charts and graphs**
- **Export functionality** (PDF, Excel)
- **Trend analysis** and predictions
- **Custom date range reporting**

### 🔔 Smart Notifications
- **Local notification system** (no external dependencies)
- **Course reminders** based on schedule
- **Attendance alerts** and summaries
- **Customizable notification preferences**

## 🚀 Quick Start

### Prerequisites
- **Node.js** 18.0.0 or higher
- **Flutter** 3.24.0 or higher
- **PostgreSQL** 12.0 or higher
- **Git** for version control

### One-Command Setup

```bash
# Clone the repository
git clone <repository-url>
cd AttendKal

# Run the development environment
./start-dev.sh
```

This script will:
- Install all dependencies
- Set up the database
- Start the backend server
- Launch the Flutter app
- Open API documentation

### Manual Setup

#### Backend Setup
```bash
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Set up database
npm run db:generate
npm run db:migrate

# Start development server
npm run dev
```

#### Flutter Setup
```bash
# Get Flutter dependencies
flutter pub get

# Run the app
flutter run
```

## 📁 Project Structure

```
AttendKal/
├── backend/                 # Node.js Express API
│   ├── src/
│   │   ├── config/         # Configuration files
│   │   ├── controllers/    # Route controllers
│   │   ├── middleware/     # Express middleware
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   └── utils/          # Utility functions
│   ├── prisma/             # Database schema & migrations
│   ├── tests/              # Backend tests
│   └── package.json
├── lib/                     # Flutter application
│   ├── core/               # Core functionality
│   │   ├── config/         # App configuration
│   │   ├── network/        # HTTP client & networking
│   │   ├── services/       # API services
│   │   └── utils/          # Utility functions
│   ├── features/           # Feature modules
│   │   ├── auth/           # Authentication
│   │   ├── courses/        # Course management
│   │   ├── attendance/     # Attendance tracking
│   │   └── subscription/   # Subscription management
│   └── main.dart
├── assets/                  # App assets (images, icons, fonts)
├── android/                # Android-specific configuration
├── ios/                    # iOS-specific configuration
├── web/                    # Web-specific configuration
└── start-dev.sh           # Development startup script
```

## 🛠️ Development

### Backend Development
```bash
cd backend

# Development with hot reload
npm run dev

# Run tests
npm test

# Run linting
npm run lint

# Generate Prisma client
npm run db:generate

# Database operations
npm run db:studio    # Open Prisma Studio
npm run db:migrate   # Run migrations
npm run db:push      # Push schema changes
```

### Flutter Development
```bash
# Hot reload development
flutter run

# Run tests
flutter test

# Generate code (models, etc.)
flutter packages pub run build_runner build

# Analyze code
flutter analyze
```

## 🧪 Testing

### Backend Testing
```bash
cd backend

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test
npm test -- --grep "authentication"
```

### Flutter Testing
```bash
# Run all tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📚 API Documentation

The backend provides comprehensive API documentation:

- **Interactive Docs**: `http://localhost:3000/api-docs`
- **API Overview**: `http://localhost:3000/api`
- **Health Check**: `http://localhost:3000/health`
- **Metrics**: `http://localhost:3000/metrics`

### Key API Endpoints

#### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh-token` - Token refresh
- `GET /api/auth/me` - Get current user

#### Courses
- `GET /api/courses` - List user courses
- `POST /api/courses` - Create new course
- `PUT /api/courses/:id` - Update course
- `DELETE /api/courses/:id` - Delete course

#### Attendance
- `GET /api/attendance` - Get attendance records
- `POST /api/attendance` - Mark attendance
- `GET /api/attendance/stats` - Attendance statistics

## 🚀 Deployment

### Backend Deployment

#### Docker (Recommended)
```bash
cd backend
docker-compose up -d
```

#### Manual Deployment
```bash
# Production build
npm run build

# Start with PM2
npm install -g pm2
pm2 start ecosystem.config.cjs
```

### Flutter Deployment

#### Web
```bash
flutter build web
# Deploy dist/ folder to your web server
```

#### Mobile
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/attendkal_db"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_REFRESH_SECRET="your-super-secret-refresh-key"

# Server
NODE_ENV="development"
PORT=3000

# Security
BCRYPT_ROUNDS=12
CORS_ORIGIN="http://localhost:3000"
```

### Flutter Configuration

The app automatically discovers the backend URL from a list of possible ports. You can customize this in `lib/core/config/app_config.dart`.

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** with proper tests
4. **Commit changes**: `git commit -m 'Add amazing feature'`
5. **Push to branch**: `git push origin feature/amazing-feature`
6. **Submit a Pull Request**

### Development Guidelines

- Follow the existing code style and patterns
- Write tests for new features
- Update documentation for API changes
- Use conventional commit messages
- Ensure all tests pass before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the `/api-docs` for backend API reference
- **Issues**: Create an issue on GitHub for bugs or feature requests
- **Development**: Use the development startup script for quick setup

## 🎯 Roadmap

- [ ] **Mobile App Optimization** - Enhanced mobile experience
- [ ] **Offline Mode** - Work without internet connection
- [ ] **Advanced Analytics** - Machine learning insights
- [ ] **Multi-language Support** - Internationalization
- [ ] **Dark Theme** - Complete dark mode implementation
- [ ] **Real-time Updates** - WebSocket integration
- [ ] **Advanced Notifications** - Smart notification scheduling

## 🏆 Credits

Built with ❤️ using modern technologies:
- **Flutter** for beautiful cross-platform UI
- **Node.js & Express** for robust backend API
- **PostgreSQL** for reliable data storage
- **Prisma** for type-safe database access
- **JWT** for secure authentication

---

**AttendKal** - Making attendance tracking simple, secure, and smart! 🎓 