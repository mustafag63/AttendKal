# AttendKal Backend API

## Genel Bakış

AttendKal uygulaması için RESTful API backend servisi. Bu proje aşağıdaki ana özellikleri sağlar:

- **Öğrenci Yönetimi**: Öğrenci CRUD işlemleri
- **Ders Yönetimi**: Ders programı ve bilgileri
- **Devamsızlık Takibi**: Yoklama kayıtları ve raporları
- **Senkronizasyon**: Offline-first mobil uygulama için senkronizasyon
- **Analytics**: İstatistik ve raporlama

## 🏗️ Teknoloji Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js + TypeScript
- **Database**: PostgreSQL + Prisma ORM
- **Cache**: Redis
- **Authentication**: JWT
- **API Documentation**: Swagger/OpenAPI
- **File Storage**: Local Storage / AWS S3
- **Logging**: Morgan + Winston
- **Testing**: Jest + Supertest

## 📋 Gereksinimler

- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- Node.js 18+

## 🚀 Hızlı Başlangıç

### Docker ile Kurulum (Önerilen)

```bash
# Ana dizine geçin
cd attendkal

# Docker ile tüm servisleri başlatın
docker-compose up -d

# Backend'in hazır olduğunu kontrol edin
curl http://localhost:3000/health

# Database migration'ları çalıştırın
docker-compose exec backend npm run db:migrate

# Seed data ekleyin (opsiyonel)
docker-compose exec backend npm run db:seed
```

### Manuel Kurulum

```bash
# Backend dizinine geçin
cd backend

# Dependencies'i yükleyin
npm install

# Database'i oluşturun
createdb attendkal_dev

# Environment dosyasını oluşturun
cp .env.example .env
# .env dosyasını düzenleyin

# Prisma migration'ları çalıştırın
npx prisma migrate dev

# Prisma client'ı generate edin
npx prisma generate

# Development server'ı başlatın
npm run dev
```

## 🔧 Yapılandırma

### Ortam Değişkenleri (.env)

```env
# Database
DATABASE_URL="postgresql://attendkal:password@localhost:5432/attendkal_dev"
DATABASE_URL_TEST="postgresql://attendkal:password@localhost:5432/attendkal_test"

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-super-secret-jwt-key-min-32-characters
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=30d

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# File Upload
MAX_FILE_SIZE=10485760  # 10MB
UPLOAD_PATH=./uploads

# Email (bildirimler için)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# App
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
API_VERSION=v1
```

## 📊 Database Schema

### Temel Modeller

```prisma
model User {
  id          String   @id @default(cuid())
  email       String   @unique
  name        String
  passwordHash String
  role        Role     @default(TEACHER)
  isActive    Boolean  @default(true)
  courses     Course[]
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@map("users")
}

model Student {
  id              String            @id @default(cuid())
  studentNumber   String            @unique
  name            String
  email           String?
  phone           String?
  classId         String?
  attendanceRecords AttendanceRecord[]
  enrollments     Enrollment[]
  isActive        Boolean           @default(true)
  createdAt       DateTime          @default(now())
  updatedAt       DateTime          @updatedAt

  @@map("students")
}

model Course {
  id              String            @id @default(cuid())
  name            String
  code            String            @unique
  description     String?
  teacherId       String
  teacher         User              @relation(fields: [teacherId], references: [id])
  semester        String
  academicYear    String
  isActive        Boolean           @default(true)
  enrollments     Enrollment[]
  attendanceRecords AttendanceRecord[]
  createdAt       DateTime          @default(now())
  updatedAt       DateTime          @updatedAt

  @@map("courses")
}

model AttendanceRecord {
  id        String            @id @default(cuid())
  studentId String
  student   Student           @relation(fields: [studentId], references: [id])
  courseId  String
  course    Course            @relation(fields: [courseId], references: [id])
  date      DateTime
  status    AttendanceStatus
  notes     String?
  createdAt DateTime          @default(now())
  updatedAt DateTime          @updatedAt

  @@unique([studentId, courseId, date])
  @@map("attendance_records")
}

enum AttendanceStatus {
  PRESENT
  ABSENT
  LATE
  EXCUSED
}
```

## 🌐 API Endpoints

### Base URL: `http://localhost:3000/api/v1`

### Authentication

```http
POST /auth/register          # Kullanıcı kaydı
POST /auth/login             # Giriş yapma
POST /auth/refresh           # Token yenileme
POST /auth/logout            # Çıkış yapma
GET  /auth/me                # Kullanıcı bilgileri
```

### Öğrenciler

```http
GET    /students             # Öğrenci listesi (pagination, search, filter)
POST   /students             # Yeni öğrenci
GET    /students/:id         # Öğrenci detayı
PUT    /students/:id         # Öğrenci güncelle
DELETE /students/:id         # Öğrenci sil (soft delete)
GET    /students/:id/attendance # Öğrencinin devamsızlık durumu
GET    /students/search      # Öğrenci arama
POST   /students/bulk        # Toplu öğrenci ekleme
```

### Dersler

```http
GET    /courses              # Ders listesi
POST   /courses              # Yeni ders
GET    /courses/:id          # Ders detayı
PUT    /courses/:id          # Ders güncelle
DELETE /courses/:id          # Ders sil
GET    /courses/:id/students # Derse kayıtlı öğrenciler
POST   /courses/:id/enroll   # Öğrenci kaydı
DELETE /courses/:id/students/:studentId # Öğrenci kaydını sil
GET    /courses/:id/attendance # Dersin devamsızlık kayıtları
```

### Devamsızlık

```http
GET    /attendance           # Devamsızlık kayıtları
POST   /attendance           # Yoklama alma
POST   /attendance/bulk      # Toplu yoklama
PUT    /attendance/:id       # Devamsızlık güncelle
DELETE /attendance/:id       # Devamsızlık sil
GET    /attendance/reports   # Devamsızlık raporları
GET    /attendance/stats     # Devamsızlık istatistikleri
GET    /attendance/export    # Excel/PDF export
```

### Senkronizasyon

```http
POST   /sync/push            # Mobil'den veri gönderme
GET    /sync/pull            # Mobil'e veri çekme
GET    /sync/status          # Senkronizasyon durumu
POST   /sync/conflict-resolve # Çakışma çözme
```

### Analytics

```http
GET    /analytics/overview   # Genel dashboard
GET    /analytics/attendance # Devamsızlık analizi
GET    /analytics/trends     # Trend analizi
GET    /analytics/students   # Öğrenci bazlı analiz
GET    /analytics/courses    # Ders bazlı analiz
```

### System

```http
GET    /health               # Sistem durumu
GET    /metrics              # Prometheus metrikleri
GET    /docs                 # API dokümantasyonu
```

## 📝 API Kullanım Örnekleri

### 1. Kullanıcı Kaydı ve Giriş

```bash
# Kullanıcı kaydı
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ahmet Öğretmen",
    "email": "ahmet@university.edu",
    "password": "securePassword123"
  }'

# Giriş yapma
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmet@university.edu",
    "password": "securePassword123"
  }'
```

### 2. Öğrenci Ekleme

```bash
curl -X POST http://localhost:3000/api/v1/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "studentNumber": "20230001",
    "name": "Mehmet Yılmaz",
    "email": "mehmet@student.edu",
    "phone": "+90 555 123 4567"
  }'
```

### 3. Ders Oluşturma

```bash
curl -X POST http://localhost:3000/api/v1/courses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "Matematik 101",
    "code": "MATH101",
    "description": "Temel matematik dersi",
    "semester": "Güz",
    "academicYear": "2023-2024"
  }'
```

### 4. Yoklama Alma

```bash
curl -X POST http://localhost:3000/api/v1/attendance/bulk \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "courseId": "course-id-here",
    "date": "2024-01-15",
    "records": [
      {
        "studentId": "student-id-1",
        "status": "PRESENT"
      },
      {
        "studentId": "student-id-2",
        "status": "ABSENT",
        "notes": "Hastalık raporu"
      },
      {
        "studentId": "student-id-3",
        "status": "LATE"
      }
    ]
  }'
```

### 5. Devamsızlık Raporu

```bash
curl -X GET "http://localhost:3000/api/v1/attendance/reports?courseId=course-id&startDate=2024-01-01&endDate=2024-01-31&format=json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 6. Analytics

```bash
# Genel istatistikler
curl -X GET http://localhost:3000/api/v1/analytics/overview \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Trend analizi
curl -X GET "http://localhost:3000/api/v1/analytics/trends?period=monthly&year=2024" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🧪 Test

### Test Komutları

```bash
# Tüm testleri çalıştır
npm test

# Test coverage ile çalıştır
npm run test:coverage

# Watch modunda çalıştır
npm run test:watch

# E2E testler
npm run test:e2e

# Specific test file
npm test -- --testPathPattern=auth
```

### Test Ortamı

```bash
# Test database oluştur
createdb attendkal_test

# Test environment'da çalıştır
NODE_ENV=test npm test

# Test database'i temizle
npm run test:db:reset
```

### Test Örnekleri

```javascript
// tests/auth.test.js
describe('Authentication', () => {
  test('should register a new user', async () => {
    const response = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123'
      });
    
    expect(response.status).toBe(201);
    expect(response.body.user.email).toBe('test@example.com');
  });
});
```

## 📚 API Dokümantasyonu

### Swagger UI

API dokümantasyonuna erişim: `http://localhost:3000/api/docs`

### Postman Collection

```bash
# Postman collection'ı indir
curl -o attendkal-api.postman_collection.json \
  https://raw.githubusercontent.com/your-username/attendkal/main/backend/docs/postman_collection.json
```

### API Response Format

Tüm API yanıtları standart format kullanır:

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "Operation successful",
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0.0"
  }
}
```

Error Response:
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "requestId": "req-123"
  }
}
```

## 🔒 Güvenlik

### Authentication & Authorization

- **JWT Tokens**: Access token (15 min) + Refresh token (30 days)
- **Role-based Access**: Admin, Teacher, Assistant rolleri
- **Password Security**: bcrypt ile hash (12 rounds)
- **Token Blacklist**: Çıkış yapılan token'lar blacklist'e eklenir

### API Güvenliği

```javascript
// Rate limiting
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
}));

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true
}));

// Security headers
app.use(helmet());

// Input validation
app.use(validator());
```

### Database Security

- **Prepared Statements**: Prisma ORM SQL injection koruması
- **Data Encryption**: Hassas veriler şifrelenir
- **Audit Logs**: Tüm CRUD işlemleri loglanır
- **Soft Delete**: Veriler fiziksel olarak silinmez

## 📈 Monitoring & Logging

### Health Check

```http
GET /health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "services": {
    "database": {
      "status": "healthy",
      "responseTime": "5ms"
    },
    "redis": {
      "status": "healthy",
      "responseTime": "2ms"
    }
  },
  "uptime": "2d 5h 30m",
  "memory": {
    "used": "150MB",
    "total": "512MB"
  }
}
```

### Metrics

```http
GET /metrics
```

Prometheus formatında metrikler:
- Request count ve duration
- Database connection pool
- Error rates
- Custom business metrics

### Logging

```javascript
// Winston logger configuration
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

## 🚀 Deployment

### Docker Production

```bash
# Production build
docker build -t attendkal-backend:latest .

# Deploy with docker-compose
docker-compose -f docker-compose.prod.yml up -d
```

### Environment Variables (Production)

```env
NODE_ENV=production
DATABASE_URL=postgresql://attendkal:secure_password@postgres:5432/attendkal_prod
REDIS_URL=redis://redis:6379
JWT_SECRET=very-long-and-secure-secret-key-for-production
LOG_LEVEL=info
CORS_ORIGINS=https://yourdomain.com
```

### Database Migration (Production)

```bash
# Run migrations
npx prisma migrate deploy

# Generate Prisma client
npx prisma generate

# Seed production data (if needed)
npx prisma db seed
```

### SSL/TLS Configuration

```nginx
# nginx.conf
server {
    listen 443 ssl;
    server_name api.attendkal.com;
    
    ssl_certificate /etc/ssl/certs/attendkal.crt;
    ssl_certificate_key /etc/ssl/private/attendkal.key;
    
    location / {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔄 Backup & Recovery

### Database Backup

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump $DATABASE_URL > /backups/attendkal_$DATE.sql
gzip /backups/attendkal_$DATE.sql

# Keep only last 30 days
find /backups -name "attendkal_*.sql.gz" -mtime +30 -delete
```

### Restore

```bash
# Restore from backup
createdb attendkal_restored
gunzip -c backup_20240115_020000.sql.gz | psql attendkal_restored
```

## 🛠️ Development

### Project Structure

```
backend/
├── src/
│   ├── controllers/        # Route handlers
│   ├── services/          # Business logic
│   ├── models/            # Database models (Prisma)
│   ├── middleware/        # Express middleware
│   ├── utils/             # Helper functions
│   ├── types/             # TypeScript types
│   ├── config/            # Configuration
│   └── routes/            # Route definitions
├── tests/                 # Test files
├── docs/                  # API documentation
├── prisma/               # Prisma schema and migrations
├── uploads/              # File uploads (development)
└── docker/               # Docker configuration
```

### Code Style

```bash
# Linting
npm run lint

# Auto-fix
npm run lint:fix

# Formatting
npm run format

# Type checking
npm run type-check
```

### Git Hooks

```bash
# Pre-commit hooks
npm run husky:install

# Runs before commit:
# - ESLint
# - Prettier
# - Type check
# - Unit tests
```

## 🤝 Contributing

### Development Workflow

1. Fork repository'yi
2. Feature branch oluştur: `git checkout -b feature/amazing-feature`
3. Değişiklikleri commit et: `git commit -m 'feat: add amazing feature'`
4. Tests yazın ve çalıştırın: `npm test`
5. Branch'i push et: `git push origin feature/amazing-feature`
6. Pull Request oluştur

### Commit Convention

```bash
feat: new feature
fix: bug fix
docs: documentation
style: formatting
refactor: code refactoring
test: adding tests
chore: maintenance
```

## 📞 Destek

- **Issues**: [GitHub Issues](https://github.com/your-username/attendkal/issues)
- **Email**: support@attendkal.com
- **Documentation**: [API Docs](https://api.attendkal.com/docs)
- **Wiki**: [Project Wiki](https://github.com/your-username/attendkal/wiki)

## 📄 License

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](../LICENSE) dosyasına bakın.

---

## 🔗 İlgili Projeler

- [AttendKal Mobile App](../mobile_app/)
- [AttendKal Web Dashboard](../web_dashboard/)
- [AttendKal Analytics](../analytics/)

## 📈 Roadmap

- [ ] GraphQL API desteği
- [ ] Real-time notifications (WebSocket)
- [ ] Advanced analytics dashboard
- [ ] Multi-tenant support
- [ ] Mobile app offline sync improvements
- [ ] AI-powered attendance predictions
