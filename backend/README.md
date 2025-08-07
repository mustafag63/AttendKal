# AttendKal Backend API

A professional Node.js Express API server for the AttendKal student attendance tracking system. This backend provides a complete RESTful API with JWT authentication, PostgreSQL database with Prisma ORM, and comprehensive features for managing courses, attendance, and subscriptions.

## 🏗️ Architecture

- **Framework**: Node.js with Express.js
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT-based authentication with refresh tokens
- **Validation**: Express Validator
- **Security**: Helmet, CORS, Rate Limiting
- **Monitoring**: Prometheus metrics, Winston logging
- **Documentation**: Swagger/OpenAPI
- **Testing**: Jest with Supertest
- **Process Management**: PM2 with ecosystem config

## 🚀 Features

### Authentication & Authorization
- JWT-based authentication with access and refresh tokens
- Role-based access control (Student, Teacher, Admin)
- Password encryption with bcrypt
- Session management with automatic token refresh

### Course Management
- Create, read, update, delete courses
- Course scheduling with time slots
- Search and filtering capabilities
- User-based course isolation

### Attendance Tracking
- Mark attendance with various statuses (Present, Absent, Late, Excused)
- GPS location tracking for attendance verification
- Attendance statistics and reporting
- Date-based attendance queries

### Subscription Management
- Free, Pro, and Premium subscription tiers
- Course limits based on subscription
- Subscription upgrade functionality
- Payment integration ready (Stripe compatible)

### Additional Features
- Comprehensive error handling and validation
- API rate limiting and security
- Health checks and monitoring
- Automatic API documentation
- Background job processing (Bull queues)
- File upload support (AWS S3 integration)

## 📋 Prerequisites

- Node.js 18.0.0 or higher
- PostgreSQL 12.0 or higher
- npm 8.0.0 or higher
- Redis (optional, for background jobs)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd AttendKal/backend
   ```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up the database**
```bash
# Generate Prisma client
npm run db:generate

   # Run database migrations
npm run db:migrate

   # (Optional) Seed the database
npm run db:seed
```

## ⚙️ Environment Configuration

Create a `.env` file with the following variables:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/attendkal_db"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRE="24h"
JWT_REFRESH_SECRET="your-super-secret-refresh-key"
JWT_REFRESH_EXPIRE="30d"

# Server
NODE_ENV="development"
PORT=3000

# Security
BCRYPT_ROUNDS=12
CORS_ORIGIN="http://localhost:3000"
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Optional: Email, AWS S3, Redis configurations
```

## 🏃‍♂️ Running the Application

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

### With PM2 (Production)
```bash
npm install -g pm2
pm2 start ecosystem.config.cjs
```

## 📚 API Documentation

Once the server is running, access the interactive API documentation at:
- **Swagger UI**: `http://localhost:3000/api-docs`
- **API Info**: `http://localhost:3000/api`
- **Health Check**: `http://localhost:3000/health`

## 🔒 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/refresh-token` - Refresh access token
- `GET /api/auth/me` - Get current user profile
- `PATCH /api/auth/update-password` - Update password
- `PATCH /api/auth/update-profile` - Update user profile

### Courses
- `GET /api/courses` - Get user courses
- `POST /api/courses` - Create new course
- `GET /api/courses/:id` - Get course details
- `PUT /api/courses/:id` - Update course
- `DELETE /api/courses/:id` - Delete course

### Attendance
- `GET /api/attendance` - Get attendance records
- `POST /api/attendance` - Mark attendance
- `GET /api/attendance/stats` - Get attendance statistics
- `GET /api/attendance/reports` - Generate attendance reports

### Subscriptions
- `GET /api/subscriptions` - Get subscription status
- `POST /api/subscriptions/upgrade` - Upgrade subscription
- `GET /api/subscriptions/current` - Get current subscription details

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## 🚀 Deployment

### Docker Deployment
```bash
# Build and run with Docker Compose
docker-compose up -d
```

### Manual Deployment
1. Set up PostgreSQL database
2. Configure environment variables
3. Run database migrations
4. Start the application with PM2

## 📊 Monitoring

- **Metrics**: Available at `/metrics` (Prometheus format)
- **Health Check**: Available at `/health`
- **Logs**: Winston logging with configurable levels
- **Performance**: Express rate limiting and monitoring

## 🔧 Database Management

```bash
# Generate Prisma client
npm run db:generate

# Run migrations
npm run db:migrate

# Push schema changes
npm run db:push

# Open Prisma Studio
npm run db:studio

# Reset database
npm run db:reset
```

## 📁 Project Structure

```
src/
├── config/           # Configuration files
├── controllers/      # Route controllers
├── dto/             # Data transfer objects
├── middleware/      # Express middleware
├── routes/          # API routes
├── services/        # Business logic
├── utils/           # Utility functions
├── server.js        # Main server file
tests/
├── unit/            # Unit tests
├── integration/     # Integration tests
└── setup.js         # Test setup
prisma/
├── schema.prisma    # Database schema
└── migrations/      # Database migrations
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Run the test suite
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the API documentation at `/api-docs`
- Review the logs for error details
- Ensure all environment variables are properly configured
- Verify database connectivity

## 🔄 Version History

- **v1.0.0**: Initial release with complete API functionality
  - JWT authentication system
  - Course and attendance management
  - Subscription handling
  - Comprehensive security and monitoring 