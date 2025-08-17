# Auth Endpoints Test Guide

## Test Commands

### 1. Register a new user
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123",
    "username": "testuser",
    "timezone": "Europe/Istanbul"
  }'
```

### 2. Login with the user
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123"
  }'
```

### 3. Get user profile (replace TOKEN with the token from login response)
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Change password (replace TOKEN with the token from login response)
```bash
curl -X POST http://localhost:3000/api/auth/change-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "currentPassword": "TestPassword123",
    "newPassword": "NewPassword456"
  }'
```

## Database Setup (Required before testing)

First, you need to set up a PostgreSQL database and run migrations:

```bash
# Install PostgreSQL (if not already installed)
# macOS: brew install postgresql
# Start PostgreSQL service
# macOS: brew services start postgresql

# Create database
createdb attendkal_db

# Update .env file with your database URL
# DATABASE_URL="postgresql://your_username:your_password@localhost:5432/attendkal_db?schema=public"

# Run migrations
npx prisma migrate dev --name init
```
