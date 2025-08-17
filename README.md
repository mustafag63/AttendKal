# 🎓 Attendkal - University Attendance Tracker

A comprehensive attendance tracking system for university students, built with Flutter (mobile) and Node.js (backend).

## 🚀 Quick Start

### Option 1: Docker (Recommended)
```bash
# Clone repository
git clone <repository-url>
cd Attendkal

# Setup and start with Docker
cp .env.example .env
docker-compose up -d

# Verify services
curl http://localhost:3000/health
```

### Option 2: Manual Setup
```bash
# Backend setup
cd backend
npm install
cp .env.example .env
npx prisma migrate dev
npm run dev

# Mobile app setup (coming soon)
cd ../mobile_app
flutter pub get
flutter run
```

## 📖 Documentation

- **[🐳 Docker Guide](DOCKER_GUIDE.md)** - Complete Docker setup and operations
- **[🔧 Backend API](backend/README.md)** - API documentation and development
- **[📱 Mobile App](mobile_app/README.md)** - Flutter app development (coming soon)

## 🏗️ Architecture

```
Attendkal/
├── backend/                 # Node.js + Express + Prisma + PostgreSQL
│   ├── src/
│   │   ├── modules/         # Feature modules
│   │   │   ├── auth/        # Authentication
│   │   │   ├── courses/     # Course management
│   │   │   ├── sessions/    # Class sessions
│   │   │   ├── attendance/  # Attendance tracking
│   │   │   └── reminders/   # Notification system
│   │   ├── lib/            # Shared utilities
│   │   └── middlewares/    # Express middlewares
│   ├── prisma/             # Database schema
│   └── docs/               # API documentation
├── mobile_app/             # Flutter mobile app (coming soon)
└── docker-compose.yml      # Docker orchestration
```

## ✨ Features

### 📚 Course Management
- Create and manage courses with details (name, code, teacher, location, color)
- Set maximum absence limits per course
- Weekly meeting schedules with automatic session generation
- Course statistics and progress tracking

### ⏰ Session & Attendance
- Automatic session generation from weekly schedules
- Manual session creation for special classes
- Attendance marking (Present/Absent/Excused)
- Real-time absence count and limit tracking
- "Last strike" warnings when approaching absence limit

### 🔔 Smart Reminders
- Course-specific and general reminders
- Customizable timing (morning of class, X minutes before)
- Threshold alerts for absence limits
- Cron-based scheduling support

### 🔐 Authentication & Security
- JWT-based authentication
- Secure password hashing with bcrypt
- Rate limiting on sensitive endpoints
- Input validation with Zod
- CORS and security headers

### 📊 Progress Tracking
- Visual attendance statistics per course
- Weekly and monthly trends
- Risk alerts for students approaching absence limits
- Comprehensive dashboard overview

## 🛠️ Technology Stack

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL 15
- **ORM**: Prisma
- **Authentication**: JWT + bcrypt
- **Validation**: Zod
- **Documentation**: OpenAPI 3.0
- **Containerization**: Docker + Docker Compose

### Frontend (Coming Soon)
- **Framework**: Flutter
- **State Management**: Riverpod
- **Local Database**: Drift
- **HTTP Client**: Dio
- **Notifications**: flutter_local_notifications
- **Background Tasks**: workmanager

## 🔧 Development

### Prerequisites
- Docker Desktop (recommended) OR
- Node.js 18+, PostgreSQL 15+, Flutter 3.0+

### Environment Setup
```bash
# With Docker
docker-compose up -d

# Manual setup
createdb attendkal_db
cd backend && npm install && npx prisma migrate dev
```

### Available Scripts
```bash
# Backend
npm run dev          # Development server
npm run build        # Production build
npm run db:migrate   # Run migrations
npm run db:studio    # Open Prisma Studio

# Docker
docker-compose up -d              # Start all services
docker-compose logs -f backend    # View backend logs
docker-compose down -v            # Reset everything
```

## 📋 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get profile

### Course Management
- `GET /api/courses` - List courses with stats
- `POST /api/courses` - Create course
- `PUT /api/courses/:id` - Update course
- `POST /api/courses/:id/meetings` - Add meeting schedule

### Sessions & Attendance
- `GET /api/sessions` - List sessions
- `POST /api/sessions/generate` - Generate from schedules
- `POST /api/attendance/:sessionId` - Mark attendance

### Reminders
- `GET /api/reminders` - List reminders
- `POST /api/reminders` - Create reminder

**Full API documentation**: [OpenAPI Spec](backend/docs/openapi.yaml)

## 🚀 Deployment

### Development
```bash
docker-compose up -d
```

### Production
```bash
# Update environment variables
cp .env.example .env
# Edit .env with production values

# Deploy with Docker
docker-compose -f docker-compose.yml up -d
```

## 🧪 Testing

```bash
# Backend tests
cd backend
npm run test

# API testing
curl http://localhost:3000/health
# See TEST_COMPLETE_API.md for full test suite
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/awesome-feature`)
3. Commit changes (`git commit -m 'Add awesome feature'`)
4. Push to branch (`git push origin feature/awesome-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the `/docs` folder and README files
- **Issues**: Open an issue on GitHub
- **Docker Problems**: See [DOCKER_GUIDE.md](DOCKER_GUIDE.md) troubleshooting section

---

**Made with ❤️ for university students everywhere**
