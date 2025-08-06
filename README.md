# AttendKal - Akıllı Devam Takip Sistemi 📚

Modern, full-stack öğrenci devam takip uygulaması. **Flutter** + **Node.js + Express** + **PostgreSQL** ile geliştirilmiştir.

## 🌟 **Özellikler**

### 📱 **Mobil Uygulama**
- ✅ **Çoklu Platform**: iOS ve Android desteği
- ✅ **Offline Çalışma**: İnternet olmadan da kullanım
- ✅ **Modern UI**: Material Design 3 arayüzü
- ✅ **Hızlı Performans**: Optimize edilmiş kod yapısı
- ✅ **Güvenli Depolama**: Şifrelenmiş yerel veritabanı

### 🎓 **Kurs Yönetimi**
- ✅ **Kurs Oluşturma**: Ad, kod, öğretmen bilgileri
- ✅ **Program Yönetimi**: Haftalık ders programı
- ✅ **Renk Kodlaması**: Her kurs için özel renk
- ✅ **Sınıf Bilgileri**: Derslik ve saat bilgileri
- ✅ **Sınırsız Kurs**: Pro plan ile sınırsız kurs

### 📊 **Devam Takibi**
- ✅ **4 Durum**: Mevcut, Yok, Geç, Mazeretli
- ✅ **Günlük İşaretleme**: Kolay devam işaretleme
- ✅ **Not Ekleme**: Her devam kaydına not
- ✅ **İstatistikler**: Detaylı devam analizi
- ✅ **Raporlama**: PDF ve Excel raporları

### 🔔 **Bildirim Sistemi**
- ✅ **E-posta Hatırlatmaları**: Ders başlamadan 15 dakika önce
- ✅ **Push Bildirimleri**: Firebase Cloud Messaging
- ✅ **Yerel Bildirimler**: Uygulama içi bildirimler
- ✅ **Haftalık Raporlar**: Otomatik haftalık özet
- ✅ **Özelleştirilebilir**: Bildirim tercihleri

### 💳 **Abonelik Sistemi**
- ✅ **Ücretsiz Plan**: 2 kurs sınırı
- ✅ **Pro Plan**: Sınırsız kurs + yıllık ödeme
- ✅ **Güvenli Ödeme**: Stripe entegrasyonu
- ✅ **Otomatik Yenileme**: Abonelik yönetimi
- ✅ **İptal/Değiştirme**: Kolay plan değişikliği

## 🏗️ **Mimari Yapı**

### **Frontend (Flutter)**
- **Framework**: Flutter 3.24+
- **State Management**: BLoC Pattern
- **Local Database**: SQLite (offline-first)
- **UI**: Material Design 3
- **Architecture**: Clean Architecture (Domain/Data/Presentation)
- **Navigation**: GoRouter
- **Dependency Injection**: GetIt

### **Backend (Node.js + Express)**
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: JWT + Refresh Tokens
- **Security**: Helmet, CORS, Rate Limiting
- **Queue System**: Bull.js (Redis)
- **Email Service**: Nodemailer
- **File Upload**: Multer

### **Veritabanı Stratejisi**
- **Primary**: PostgreSQL (production data)
- **Local**: SQLite (offline caching)
- **Sync**: Automatic background synchronization
- **Redis**: Queue management ve caching

## 🛠️ **Teknoloji Stack'i**

| Bileşen | Teknoloji | Amaç |
|---------|-----------|------|
| **Mobil Uygulama** | Flutter + Dart | Cross-platform mobile |
| **Backend API** | Node.js + Express | REST API server |
| **Veritabanı** | PostgreSQL + Prisma | Primary data storage |
| **Local DB** | SQLite | Offline caching |
| **Queue System** | Redis + Bull.js | Background jobs |
| **Auth** | JWT + Refresh Tokens | Secure authentication |
| **State Management** | Flutter BLoC | Predictable state |
| **Navigation** | GoRouter | Declarative routing |
| **Notifications** | FCM + Local | Push notifications |
| **Networking** | Dio + Interceptors | HTTP client |
| **Validation** | Express Validator | Input validation |
| **Logging** | Winston | Structured logging |
| **Testing** | Jest + Flutter Test | Unit & Widget tests |
| **Email** | Nodemailer | Email notifications |
| **File Storage** | Multer | File uploads |
| **Monitoring** | Prometheus + Grafana | Performance monitoring |

## 📁 **Proje Yapısı**

```
AttendKal/
├── lib/                          # Flutter uygulaması
│   ├── core/
│   │   ├── config/              # Uygulama konfigürasyonu
│   │   │   └── app_config.dart  # Sabit değerler
│   │   ├── di/                  # Dependency injection
│   │   │   └── injection_container.dart
│   │   ├── network/             # API client & network
│   │   │   ├── api_client.dart  # HTTP client
│   │   │   └── network_info.dart
│   │   ├── routes/              # Uygulama routing
│   │   │   └── app_router.dart
│   │   ├── theme/               # UI temaları
│   │   │   └── app_theme.dart
│   │   ├── utils/               # Yardımcı fonksiyonlar
│   │   │   └── notification_service.dart
│   │   └── database/            # Yerel veritabanı
│   │       └── database_helper.dart
│   ├── features/
│   │   ├── auth/                # Kimlik doğrulama
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── user.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   └── auth_bloc.dart
│   │   │       └── pages/
│   │   │           ├── login_page.dart
│   │   │           └── register_page.dart
│   │   ├── courses/             # Kurs yönetimi
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── course.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   └── courses_bloc.dart
│   │   │       └── pages/
│   │   │           ├── courses_page.dart
│   │   │           └── add_course_page.dart
│   │   ├── attendance/          # Devam takibi
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── attendance.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   └── attendance_bloc.dart
│   │   │       └── pages/
│   │   │           └── attendance_page.dart
│   │   ├── subscription/        # Abonelik planları
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── subscription.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   └── subscription_bloc.dart
│   │   │       └── pages/
│   │   │           └── subscription_page.dart
│   │   ├── home/                # Ana sayfa
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── home_page.dart
│   │   ├── profile/             # Kullanıcı profili
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── profile_page.dart
│   │   └── splash/              # Açılış ekranı
│   │       └── presentation/
│   │           └── pages/
│   │               └── splash_page.dart
│   └── main.dart
├── backend/                      # Node.js API server
│   ├── src/
│   │   ├── controllers/         # Route controller'ları
│   │   │   ├── authController.js
│   │   │   ├── courseController.js
│   │   │   ├── attendanceController.js
│   │   │   └── subscriptionController.js
│   │   ├── middleware/          # Custom middleware
│   │   │   ├── authMiddleware.js
│   │   │   ├── errorHandler.js
│   │   │   ├── validationMiddleware.js
│   │   │   ├── requestLogger.js
│   │   │   └── metricsMiddleware.js
│   │   ├── routes/              # API routes
│   │   │   ├── authRoutes.js
│   │   │   ├── courseRoutes.js
│   │   │   ├── attendanceRoutes.js
│   │   │   ├── subscriptionRoutes.js
│   │   │   ├── healthRoutes.js
│   │   │   └── queueRoutes.js
│   │   ├── services/            # Business logic
│   │   │   ├── authService.js
│   │   │   ├── courseService.js
│   │   │   ├── attendanceService.js
│   │   │   ├── subscriptionService.js
│   │   │   ├── emailService.js
│   │   │   ├── queueService.js
│   │   │   └── reportService.js
│   │   ├── dto/                 # Data Transfer Objects
│   │   │   ├── authDto.js
│   │   │   ├── courseDto.js
│   │   │   └── attendanceDto.js
│   │   ├── config/              # Konfigürasyon
│   │   │   ├── index.js
│   │   │   ├── logger.js
│   │   │   └── swagger.js
│   │   ├── utils/               # Yardımcı fonksiyonlar
│   │   │   └── prisma.js
│   │   └── server.js            # Ana server dosyası
│   ├── prisma/
│   │   └── schema.prisma        # Veritabanı şeması
│   ├── tests/                   # Test dosyaları
│   │   ├── setup.js
│   │   └── unit/
│   │       └── services/
│   │           └── authService.test.js
│   ├── docker-compose.yml       # Docker compose
│   ├── Dockerfile               # Docker image
│   ├── jest.config.js           # Jest konfigürasyonu
│   └── package.json
├── android/                      # Android konfigürasyonu
├── ios/                         # iOS konfigürasyonu
├── assets/                      # Statik dosyalar
│   ├── fonts/
│   ├── icons/
│   └── images/
├── k8s/                         # Kubernetes deployment
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secrets.yaml
├── monitoring/                  # Monitoring konfigürasyonu
│   └── grafana-dashboard.json
├── cloudflare/                  # Cloudflare workers
│   └── workers/
│       └── security-worker.js
├── pubspec.yaml                 # Flutter dependencies
├── pubspec.lock
└── README.md
```

## 🔧 **Kurulum ve Yapılandırma**

### **Gereksinimler**
- Flutter 3.24+
- Node.js 18+
- PostgreSQL 12+
- Redis 6+
- Git

### **1. Repository Klonlama**
```bash
git clone https://github.com/yourusername/AttendKal.git
cd AttendKal
```

### **2. Backend Kurulumu**

#### **A) Bağımlılıkları Yükleme**
```bash
cd backend

# NPM bağımlılıklarını yükle
npm install

# Global bağımlılıklar (opsiyonel)
npm install -g nodemon prisma
```

#### **B) Ortam Değişkenleri**
```bash
# .env dosyasını kopyala
cp .env.example .env

# .env dosyasını düzenle
nano .env
```

#### **C) .env Dosyası İçeriği**
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/attendkal"

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Email (Gmail örneği)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
EMAIL_FROM=AttendKal <your-email@gmail.com>

# App
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000
FRONTEND_URL=http://localhost:8080

# Firebase (Push notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email

# Stripe (Payments)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Monitoring
PROMETHEUS_PORT=9090
```

#### **D) Veritabanı Kurulumu**
```bash
# Prisma client'ı oluştur
npm run db:generate

# Migration'ları çalıştır
npm run db:migrate

# Seed data ekle (opsiyonel)
npm run db:seed
```

#### **E) Redis Kurulumu**
```bash
# macOS (Homebrew)
brew install redis
brew services start redis

# Ubuntu/Debian
sudo apt-get install redis-server
sudo systemctl start redis-server

# Windows (WSL veya Docker)
docker run -d -p 6379:6379 redis:alpine
```

#### **F) Development Server'ı Başlat**
```bash
# Development modunda çalıştır
npm run dev

# Production modunda çalıştır
npm start

# PM2 ile çalıştır (production)
npm install -g pm2
pm2 start ecosystem.config.js
```

### **3. Flutter Kurulumu**

#### **A) Bağımlılıkları Yükleme**
```bash
# Root dizine dön
cd ..

# Flutter bağımlılıklarını yükle
flutter pub get

# iOS için (macOS gerekli)
cd ios
pod install
cd ..
```

#### **B) Firebase Kurulumu (Push Notifications)**
```bash
# Firebase CLI yükle
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# Firebase projesini başlat
firebase init

# google-services.json ve GoogleService-Info.plist dosyalarını ekle
# android/app/google-services.json
# ios/Runner/GoogleService-Info.plist
```

#### **C) Uygulamayı Çalıştır**
```bash
# Cihaz listesini gör
flutter devices

# Android'de çalıştır
flutter run -d android

# iOS'ta çalıştır
flutter run -d ios

# Web'de çalıştır
flutter run -d chrome
```

### **4. Docker ile Kurulum (Opsiyonel)**

#### **A) Docker Compose ile Tüm Servisler**
```bash
# Backend dizininde
cd backend

# Tüm servisleri başlat
docker-compose up -d

# Logları kontrol et
docker-compose logs -f
```

#### **B) Docker Compose Dosyası**
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: attendkal
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/attendkal
      REDIS_HOST: redis
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
```

## 📚 **API Dokümantasyonu**

### **Base URL**: `http://localhost:3000/api`

### **Authentication Endpoints**
```http
POST   /auth/register           # Yeni kullanıcı kaydı
POST   /auth/login              # Kullanıcı girişi
POST   /auth/logout             # Kullanıcı çıkışı
POST   /auth/refresh-token      # Access token yenileme
GET    /auth/me                 # Mevcut kullanıcı bilgileri
PATCH  /auth/update-password    # Şifre güncelleme
PATCH  /auth/update-profile     # Profil güncelleme
```

### **Course Management**
```http
GET    /courses                 # Kullanıcının kurslarını getir
POST   /courses                 # Yeni kurs oluştur
GET    /courses/:id             # Kurs detaylarını getir
PUT    /courses/:id             # Kurs güncelle
DELETE /courses/:id             # Kurs sil
```

### **Attendance Tracking**
```http
GET    /attendance              # Tüm devam kayıtlarını getir
POST   /attendance              # Devam işaretle
GET    /attendance/course/:id   # Kurs devam kayıtlarını getir
GET    /attendance/stats/:id    # Devam istatistiklerini getir
```

### **Subscription Management**
```http
GET    /subscriptions           # Abonelik durumunu getir
POST   /subscriptions/upgrade   # Pro plana yükselt
POST    /subscriptions/cancel    # Aboneliği iptal et
```

### **Queue Management (Admin)**
```http
GET    /admin/queues            # Queue durumlarını getir
POST   /admin/queues/test/email # Test e-postası gönder
POST   /admin/queues/test/report # Test raporu oluştur
POST   /admin/queues/pause/:name # Queue'yu duraklat
POST   /admin/queues/resume/:name # Queue'yu devam ettir
```

### **Health Check**
```http
GET    /health                  # Sistem sağlık durumu
GET    /health/db              # Veritabanı bağlantısı
GET    /health/redis           # Redis bağlantısı
```

## 🔒 **Güvenlik Özellikleri**

### **Authentication & Authorization**
- **JWT Authentication** with automatic refresh
- **Password hashing** with bcrypt (12 rounds)
- **Refresh token rotation** for security
- **Session management** with Redis
- **Role-based access control** (Student/Teacher/Admin)

### **API Security**
- **Rate limiting** (100 requests/15 minutes)
- **CORS** configuration
- **Input validation** on all endpoints
- **SQL injection** protection with Prisma
- **XSS protection** with Helmet.js
- **Request logging** and monitoring

### **Data Protection**
- **Encrypted local storage** in Flutter
- **Secure token storage** with biometric authentication
- **Data backup** and recovery procedures
- **GDPR compliance** features

## 🎯 **MoSCoW Gereksinimleri**

### **Must Have** ✅
- [x] Student course schedule management
- [x] Attendance marking (Present/Absent/Late/Excused)
- [x] Offline storage with SQLite
- [x] Free plan (2 courses maximum)
- [x] Pro plan (unlimited courses + annual payment)
- [x] Push notifications
- [x] Cloud backup with PostgreSQL
- [x] Email reminders (15 minutes before class)
- [x] Weekly attendance reports
- [x] User authentication & authorization

### **Should Have** 🔄
- [ ] Attendance analytics & statistics
- [ ] Custom themes (Light/Dark)
- [ ] Smart notifications based on schedule
- [ ] Data export functionality
- [ ] Profile photo upload
- [ ] Multi-language support

### **Could Have** 📋
- [ ] PDF report generation
- [ ] Advanced analytics dashboard
- [ ] Calendar integration
- [ ] Social sharing features
- [ ] Voice commands
- [ ] QR code attendance

### **Won't Have** ❌
- ❌ Multi-user collaboration
- ❌ Video call integration
- ❌ Social features
- ❌ Real-time chat

## 🧪 **Test Stratejisi**

### **Backend Tests**
```bash
cd backend

# Tüm testleri çalıştır
npm test

# Watch modunda çalıştır
npm run test:watch

# Coverage raporu
npm run test:coverage

# Integration testleri
npm run test:integration

# E2E testleri
npm run test:e2e
```

### **Flutter Tests**
```bash
# Unit testleri
flutter test test/unit/

# Widget testleri
flutter test test/widget/

# Integration testleri
flutter test test/integration/

# Coverage raporu
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### **Test Coverage Hedefleri**
- **Backend**: %90+ unit test coverage
- **Flutter**: %80+ widget test coverage
- **Integration**: Critical user flows
- **E2E**: Complete user journeys

## 🚀 **Deployment**

### **Backend Deployment (Docker)**

#### **A) Docker Image Build**
```bash
cd backend

# Production image oluştur
docker build -t attendkal-backend:latest .

# Image'ı test et
docker run -p 3000:3000 attendkal-backend:latest
```

#### **B) Docker Compose Production**
```bash
# Production compose dosyası
docker-compose -f docker-compose.prod.yml up -d

# SSL ile nginx reverse proxy
docker-compose -f docker-compose.prod.yml -f docker-compose.nginx.yml up -d
```

### **Flutter Build**

#### **A) Android APK**
```bash
# Release APK
flutter build apk --release

# Split APK (boyut optimizasyonu)
flutter build apk --split-per-abi --release

# Bundle (Google Play için)
flutter build appbundle --release
```

#### **B) iOS IPA**
```bash
# Release IPA
flutter build ios --release

# Archive ve export
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner archive
```

#### **C) Web Build**
```bash
# Web build
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### **Cloud Deployment**

#### **A) AWS Deployment**
```bash
# ECS Fargate deployment
aws ecs create-service --cluster attendkal --service-name backend

# RDS PostgreSQL setup
aws rds create-db-instance --db-instance-identifier attendkal-db

# ElastiCache Redis setup
aws elasticache create-cache-cluster --cache-cluster-id attendkal-redis
```

#### **B) Google Cloud Deployment**
```bash
# Cloud Run deployment
gcloud run deploy attendkal-backend --source .

# Cloud SQL setup
gcloud sql instances create attendkal-db

# Memorystore Redis setup
gcloud redis instances create attendkal-redis
```

#### **C) DigitalOcean Deployment**
```bash
# App Platform deployment
doctl apps create --spec app.yaml

# Managed Database
doctl databases create attendkal-db --engine pg
```

## 📊 **Veritabanı Şeması**

### **Ana Tablolar**

#### **Users Tablosu**
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT,
  role UserRole DEFAULT 'STUDENT',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### **Courses Tablosu**
```sql
CREATE TABLE courses (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  description TEXT,
  instructor TEXT NOT NULL,
  color TEXT DEFAULT '#2196F3',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, code)
);
```

#### **CourseSchedule Tablosu**
```sql
CREATE TABLE course_schedules (
  id TEXT PRIMARY KEY,
  course_id TEXT REFERENCES courses(id),
  day_of_week INTEGER NOT NULL, -- 0=Sunday, 1=Monday, etc.
  start_time TEXT NOT NULL, -- HH:MM format
  end_time TEXT NOT NULL, -- HH:MM format
  room TEXT
);
```

#### **Attendance Tablosu**
```sql
CREATE TABLE attendances (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  course_id TEXT REFERENCES courses(id),
  date DATE NOT NULL,
  status AttendanceStatus NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, course_id, date)
);
```

#### **Subscriptions Tablosu**
```sql
CREATE TABLE subscriptions (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) UNIQUE,
  type SubscriptionType NOT NULL,
  start_date TIMESTAMP DEFAULT NOW(),
  end_date TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Enum Tipleri**
```sql
CREATE TYPE UserRole AS ENUM ('STUDENT', 'TEACHER', 'ADMIN');
CREATE TYPE AttendanceStatus AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');
CREATE TYPE SubscriptionType AS ENUM ('FREE', 'PRO');
```

## 🔄 **Veri Akışı**

### **1. Kullanıcı Kimlik Doğrulama**
```
Flutter App → JWT Token → Backend API → PostgreSQL
                ↓
            Refresh Token → Redis Session Store
```

### **2. Offline-First Stratejisi**
```
Local SQLite ← → Background Sync ← → PostgreSQL
     ↓              ↓                    ↓
Offline Usage   Conflict Resolution   Cloud Backup
```

### **3. Bildirim Sistemi**
```
Course Schedule → Bull.js Queue → Email Service → User
      ↓              ↓              ↓
  Local Notification ← Firebase FCM ← Push Service
```

### **4. Abonelik Yönetimi**
```
Stripe Webhook → Backend API → Database Update → User Notification
      ↓              ↓              ↓
Payment Success   Plan Upgrade   Feature Unlock
```

## 📈 **Performans Optimizasyonları**

### **Backend Optimizasyonları**
- **Database indexing** for frequently queried fields
- **Connection pooling** with Prisma
- **Response caching** with appropriate headers
- **Query optimization** and pagination
- **Background job processing** with Bull.js

### **Flutter Optimizasyonları**
- **Image optimization** and lazy loading
- **Bundle size optimization** with tree shaking
- **Memory management** and garbage collection
- **Network request optimization** with caching
- **UI performance** with const constructors

### **Database Optimizasyonları**
```sql
-- Indexes for performance
CREATE INDEX idx_courses_user_id ON courses(user_id);
CREATE INDEX idx_attendance_course_date ON attendances(course_id, date);
CREATE INDEX idx_attendance_user_date ON attendances(user_id, date);
CREATE INDEX idx_schedules_course_day ON course_schedules(course_id, day_of_week);
```

## 🔧 **Monitoring ve Logging**

### **Application Monitoring**
- **Prometheus** metrics collection
- **Grafana** dashboards
- **Health checks** for all services
- **Performance monitoring** with APM

### **Logging Strategy**
```javascript
// Structured logging with Winston
logger.info('User logged in', {
  userId: user.id,
  email: user.email,
  timestamp: new Date().toISOString(),
  userAgent: req.headers['user-agent']
});
```

### **Error Tracking**
- **Sentry** integration for error tracking
- **Custom error handling** middleware
- **Error reporting** to monitoring systems

## 🤝 **Katkıda Bulunma**

### **Development Workflow**
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Follow coding standards and conventions
4. Write tests for new features
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open Pull Request

### **Coding Standards**
- **Backend**: ESLint + Prettier
- **Flutter**: Dart Analysis + Custom Lints
- **Git**: Conventional Commits
- **Documentation**: JSDoc + DartDoc

### **Testing Requirements**
- Unit tests for all business logic
- Integration tests for API endpoints
- Widget tests for UI components
- E2E tests for critical user flows

## 📄 **Lisans**

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🆘 **Destek**

### **Dokümantasyon**
- **API Docs**: [Swagger UI](http://localhost:3000/api-docs)
- **Wiki**: [GitHub Wiki](https://github.com/yourusername/AttendKal/wiki)
- **Code Documentation**: [JSDoc](http://localhost:3000/docs)

### **İletişim**
- **Issues**: [GitHub Issues](https://github.com/yourusername/AttendKal/issues)
- **Email**: support@attendkal.com
- **Discord**: [AttendKal Community](https://discord.gg/attendkal)

### **Sık Sorulan Sorular**
- **Kurulum Sorunları**: [Installation FAQ](https://github.com/yourusername/AttendKal/wiki/Installation-FAQ)
- **API Kullanımı**: [API Guide](https://github.com/yourusername/AttendKal/wiki/API-Guide)
- **Mobil Uygulama**: [Mobile App Guide](https://github.com/yourusername/AttendKal/wiki/Mobile-App-Guide)

---

**AttendKal Ekibi tarafından ❤️ ile geliştirildi**

### **Hızlı Başlangıç Komutları**
```bash
# Backend
cd backend && npm install && npm run dev

# Flutter
flutter pub get && flutter run

# Docker (tüm servisler)
cd backend && docker-compose up -d

# Test
npm test && flutter test
```

### **Geliştirme Ortamı Kontrol Listesi**
- [ ] Node.js 18+ yüklü
- [ ] Flutter 3.24+ yüklü
- [ ] PostgreSQL çalışıyor
- [ ] Redis çalışıyor
- [ ] .env dosyası yapılandırıldı
- [ ] Firebase projesi kuruldu
- [ ] Tüm testler geçiyor
- [ ] Uygulama çalışıyor 