# 🐳 Docker Quick Start Guide

## Prerequisites

- Docker Desktop installed and running
- Docker Compose v2.0+ (included with Docker Desktop)

## 🚀 First Time Setup

### 1. Clone and Setup Environment
```bash
# Clone repository
git clone <repository-url>
cd Attendkal

# Create environment file
cp .env.example .env

# Edit .env file with your configuration (optional)
nano .env
```

### 2. Build and Start Services
```bash
# Start all services (database + backend)
docker-compose up -d

# Check services are running
docker-compose ps
```

### 3. Verify Everything is Working
```bash
# Check backend health
curl http://localhost:3000/health

# Expected response:
# {"status":"OK","timestamp":"2025-08-17T...","environment":"production","version":"1.0.0"}
```

## 📋 Available Services

| Service | URL | Description |
|---------|-----|-------------|
| Backend API | http://localhost:3000 | Main application |
| Health Check | http://localhost:3000/health | Service status |
| PostgreSQL | localhost:5432 | Database (internal) |
| PgAdmin* | http://localhost:5050 | Database admin UI |

*PgAdmin is optional, start with: `docker-compose --profile admin up -d`

## 🔧 Common Commands

### Service Management
```bash
# Start all services
docker-compose up -d

# Start with PgAdmin
docker-compose --profile admin up -d

# Stop all services
docker-compose down

# Restart backend only
docker-compose restart backend

# View logs
docker-compose logs -f backend
docker-compose logs -f db
```

### Development & Debugging
```bash
# View real-time logs
docker-compose logs -f

# Access backend container shell
docker-compose exec backend sh

# Access database directly
docker-compose exec db psql -U attendkal_user -d attendkal_db

# Rebuild after code changes
docker-compose up -d --build backend
```

### Database Operations
```bash
# Reset database (⚠️ DESTRUCTIVE)
docker-compose down -v
docker-compose up -d

# Run migrations manually
docker-compose exec backend npx prisma migrate deploy

# Access Prisma Studio
docker-compose exec backend npx prisma studio
```

## 🔍 Health Checks & Monitoring

### Check Service Status
```bash
# All services status
docker-compose ps

# Detailed health info
docker-compose exec backend wget -qO- http://localhost:3000/health | jq .
```

### Expected Healthy Output
```bash
$ docker-compose ps
NAME                STATUS              PORTS
attendkal-backend   Up (healthy)        0.0.0.0:3000->3000/tcp
attendkal-db        Up (healthy)        0.0.0.0:5432->5432/tcp
```

## 🐛 Troubleshooting

### Backend Won't Start
```bash
# Check backend logs
docker-compose logs backend

# Common issues:
# 1. Database not ready - wait longer
# 2. Migration failed - check DATABASE_URL
# 3. Port conflict - change PORT in .env
```

### Database Connection Issues
```bash
# Check database is running
docker-compose exec db pg_isready -U attendkal_user

# Reset database connection
docker-compose restart db
docker-compose restart backend
```

### Clean Slate Reset
```bash
# Remove everything and start fresh
docker-compose down -v --remove-orphans
docker system prune -f
docker-compose up -d
```

## 🔐 Environment Variables

Key variables in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | production | Application environment |
| `PORT` | 3000 | Backend port |
| `DB_USER` | attendkal_user | Database username |
| `DB_PASSWORD` | attendkal_password | Database password |
| `JWT_SECRET` | (change this!) | JWT signing secret |

## 🎯 API Testing

### Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@university.edu",
    "password": "SecurePass123",
    "username": "testuser"
  }'
```

### Login & Test Protected Endpoint
```bash
# Login and get token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@university.edu","password":"SecurePass123"}' \
  | jq -r '.data.token')

# Test protected endpoint
curl -H "Authorization: Bearer $TOKEN" http://localhost:3000/api/courses
```

## 📊 Production Deployment

For production deployment:

1. Update `.env` with production values
2. Set strong `JWT_SECRET`
3. Use external PostgreSQL if needed
4. Consider using `docker-compose.prod.yml` with:
   - Resource limits
   - Health checks
   - Logging configuration
   - Security constraints

```bash
# Production deployment
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
