# Attendkal Backend

University attendance tracker backend API built with Node.js, Express, TypeScript, and Prisma.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn
## 🚀 Features Completed
- ✅ **Authentication System** - JWT with refresh tokens, bcrypt password hashing
- ✅ **Course Management** - CRUD operations with meeting schedules
- ✅ **Session Tracking** - Automatic and manual session generation
- ✅ **Attendance System** - Present/Absent/Excused status with statistics
- ✅ **Reminder System** - Smart notifications for upcoming sessions
- ✅ **Docker Deployment** - Complete containerization with PostgreSQL
- ✅ **Database Schema** - Prisma ORM with 5 models and proper relations
- ✅ **API Documentation** - Complete endpoint testing guides

## 🎯 Next Steps

### Development
1. Test the complete Docker setup:
   ```bash
   docker-compose up -d
   ```

2. Run API tests:
   ```bash
   # See docs/TEST_COMPLETE_API.md for comprehensive testing
   curl http://localhost:3000/health
   ```

### Frontend Development
- Flutter mobile app with Riverpod state management
- Drift local database for offline functionality
- Course schedule and attendance tracking UI

## 🛟 Support

- [Docker Guide](./DOCKER_GUIDE.md) - Setup and troubleshooting
- [API Testing](./docs/TEST_COMPLETE_API.md) - Complete endpoint tests
- [OpenAPI Documentation](./docs/openapi.yaml) - API specification

---

**Attendkal Backend** - Built with ❤️ for university attendance trackingreSQL (optional with Docker)

### Installation

#### Option 1: With Docker (Recommended)
```bash
# Clone and navigate to backend
git clone <repository-url>
cd Attendkal/backend

# Start with Docker Compose
docker-compose up -d

# Check status
docker-compose ps
```

#### Option 2: Manual Setup
1. Clone the repository
```bash
git clone <repository-url>
cd Attendkal/backend
```

2. Install dependencies
```bash
npm install
```

3. Setup environment variables
```bash
cp .env.example .env
# Edit .env file with your configuration
```

4. Setup database (PostgreSQL required)
```bash
# Create database
createdb attendkal_db

# Run migrations (for manual setup)
npm run db:generate
npx prisma migrate dev --name init
```

5. Start development server
```bash
npm run dev
```

The server will start on http://localhost:3000

## 📚 Documentation

- [Docker Setup Guide](./DOCKER_GUIDE.md) - Comprehensive Docker setup and troubleshooting
- [Complete API Testing](./docs/TEST_COMPLETE_API.md) - Test all endpoints with curl commands

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint errors
- `npm run format` - Format code with Prettier
- `npm run db:generate` - Generate Prisma client
- `npm run db:migrate` - Run database migrations
- `npm run db:reset` - Reset database
- `npm run db:studio` - Open Prisma Studio

### API Endpoints

#### Health Check
- `GET /health` - Server health status

#### API Info
- `GET /api` - API information

#### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile (protected)
- `POST /api/auth/change-password` - Change password (protected)

#### Courses
- `GET /api/courses` - Get user courses with statistics
- `POST /api/courses` - Create new course
- `GET /api/courses/:id` - Get course details
- `PUT /api/courses/:id` - Update course
- `DELETE /api/courses/:id` - Delete course

#### Meetings
- `POST /api/courses/:id/meetings` - Add meeting to course
- `DELETE /api/courses/:id/meetings/:mid` - Delete meeting

#### Sessions
- `GET /api/sessions` - Get sessions (with filtering)
- `POST /api/sessions/generate` - Generate sessions from meetings
- `POST /api/sessions/:courseId` - Create manual session

#### Attendance
- `GET /api/attendance/:sessionId` - Get attendance for session
- `POST /api/attendance/:sessionId` - Mark attendance

#### Reminders
- `GET /api/reminders` - Get user reminders
- `POST /api/reminders` - Create reminder
- `GET /api/reminders/:id` - Get reminder details
- `PUT /api/reminders/:id` - Update reminder
- `DELETE /api/reminders/:id` - Delete reminder

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── app.ts              # Express app configuration
│   ├── server.ts           # Server entry point
│   ├── config/
│   │   └── env.ts          # Environment configuration
│   ├── middlewares/
│   │   ├── auth.ts         # Authentication middleware
│   │   └── error.ts        # Error handling middleware
│   └── modules/
│       ├── auth/           # Authentication module
│       ├── courses/        # Course management
│       ├── sessions/       # Session handling
│       ├── attendance/     # Attendance tracking
│       └── reminders/      # Reminder system
├── prisma/
│   ├── schema.prisma       # Database schema
│   └── migrations/         # Database migrations
├── docker/
│   └── docker-entrypoint.sh # Docker startup script
├── docs/                   # API documentation
├── dist/                   # Built files (generated)
├── Dockerfile              # Docker container config
├── docker-compose.yml      # Docker orchestration
├── package.json
├── tsconfig.json
└── .eslintrc.json
```

## 🔧 Configuration

### Environment Variables
Copy `.env.example` to `.env` and configure:

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret
- `JWT_EXPIRES_IN` - JWT expiration time
- `FRONTEND_URL` - Frontend URL for CORS

### Docker Services
- **PostgreSQL**: Database server on port 5432
- **Backend API**: Node.js server on port 3000
- **PgAdmin**: Database admin interface on port 5050 (optional)

## 📝 Development

### Code Style
- ESLint for linting
- Prettier for formatting
- TypeScript for type safety
- Prisma for database operations

### Import Aliases
- `@src/*` - src directory
- `@config/*` - config directory
- `@middlewares/*` - middlewares directory
- `@modules/*` - modules directory

## � Features Completed
- ✅ **Authentication System** - JWT with refresh tokens, bcrypt password hashing
- ✅ **Course Management** - CRUD operations with meeting schedules
- ✅ **Session Tracking** - Automatic and manual session generation
- ✅ **Attendance System** - Present/Absent/Excused status with statistics
- ✅ **Reminder System** - Smart notifications for upcoming sessions
- ✅ **Docker Deployment** - Complete containerization with PostgreSQL
- ✅ **Database Schema** - Prisma ORM with 5 models and proper relations
- ✅ **API Documentation** - Complete endpoint testing guides
- User management (profile update, email verification)
- Course management
- Reminder system
- Progress tracking
