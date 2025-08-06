# AttendKal Backend API

Modern, secure, and scalable Node.js + Express backend for AttendKal student attendance tracking system.

## 🚀 **Tech Stack**

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: JWT + Refresh Tokens
- **Security**: Helmet, CORS, Rate Limiting
- **Logging**: Winston
- **Validation**: Express Validator
- **Testing**: Jest + Supertest

## 📁 **Project Structure**

```
backend/
├── src/
│   ├── config/         # Configuration files
│   ├── controllers/    # Route controllers
│   ├── middleware/     # Custom middleware
│   ├── models/         # Database models (Prisma)
│   ├── routes/         # API routes
│   ├── services/       # Business logic services
│   ├── utils/          # Utility functions
│   └── server.js       # Main server file
├── prisma/
│   ├── schema.prisma   # Database schema
│   └── seed.js         # Database seeding
├── tests/              # Test files
├── logs/               # Log files
└── package.json
```

## 🛠️ **Setup & Installation**

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- npm or yarn

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
```bash
cp .env.example .env
```

Edit `.env` file with your configuration:
```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://username:password@localhost:5432/attendkal"
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key
```

### 3. Database Setup
```bash
# Generate Prisma client
npm run db:generate

# Create and migrate database
npm run db:migrate

# Seed database (optional)
npm run db:seed
```

### 4. Start Development Server
```bash
npm run dev
```

## 📚 **API Endpoints**

### Authentication
```http
POST   /api/auth/register       # Register new user
POST   /api/auth/login          # Login user
POST   /api/auth/logout         # Logout user
POST   /api/auth/refresh-token  # Refresh access token
GET    /api/auth/me             # Get current user
PATCH  /api/auth/update-password # Update password
PATCH  /api/auth/update-profile  # Update profile
```

### Courses
```http
GET    /api/courses             # Get user courses
POST   /api/courses             # Create course
GET    /api/courses/:id         # Get course by ID
PUT    /api/courses/:id         # Update course
DELETE /api/courses/:id         # Delete course
```

### Attendance
```http
GET    /api/attendance          # Get attendance records
POST   /api/attendance          # Mark attendance
GET    /api/attendance/course/:id # Get course attendance
GET    /api/attendance/stats/:id  # Get attendance statistics
```

### Subscriptions
```http
GET    /api/subscriptions       # Get subscription status
POST   /api/subscriptions/upgrade # Upgrade subscription
POST   /api/subscriptions/cancel  # Cancel subscription
```

### Users (Admin only)
```http
GET    /api/users               # Get all users
GET    /api/users/:id           # Get user by ID
PATCH  /api/users/:id/activate  # Activate user
PATCH  /api/users/:id/deactivate # Deactivate user
```

## 🔒 **Security Features**

- **JWT Authentication** with refresh tokens
- **Password hashing** with bcrypt
- **Rate limiting** to prevent abuse
- **CORS** configuration
- **Helmet.js** for security headers
- **Input validation** with express-validator
- **SQL injection** protection with Prisma
- **XSS protection** built-in

## 📊 **Database Schema**

### Users
- ID, email, password, name, avatar, role
- Timestamps and soft delete support

### Courses
- Course information, schedule, instructor
- User ownership and color coding

### Attendance
- Date, status (Present/Absent/Late/Excused)
- Course and user relationships

### Subscriptions
- Free/Pro plans with course limits
- Payment integration ready

## 🧪 **Testing**

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

## 📝 **Development Scripts**

```bash
npm run dev          # Start development server
npm start            # Start production server
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint errors
npm run format       # Format code with Prettier
npm run db:generate  # Generate Prisma client
npm run db:migrate   # Run database migrations
npm run db:studio    # Open Prisma Studio
npm run db:seed      # Seed database
```

## 🚀 **Deployment**

### Docker (Recommended)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run db:generate
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Variables for Production
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://...
JWT_SECRET=strong-production-secret
JWT_REFRESH_SECRET=strong-refresh-secret
CORS_ORIGIN=https://yourdomain.com
```

## 📈 **Performance Optimizations**

- **Database indexing** for frequently queried fields
- **Connection pooling** with Prisma
- **Response compression** with gzip
- **Logging optimization** for production
- **Memory leak prevention** with proper cleanup

## 🔧 **Monitoring & Logging**

- **Winston** for structured logging
- **Request/Response** logging
- **Error tracking** with stack traces
- **Performance metrics** ready for integration

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

For support, email support@attendkal.com or join our Slack channel.

---

**Made with ❤️ by the AttendKal Team** 