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

## 🏗️ **Proje Komponentleri ve İşlevleri**

### 📱 **Frontend (Flutter Uygulaması)**
**Dizin**: `/lib/`
**Amaç**: Çoklu platform mobil uygulama (iOS, Android, Web)
**Teknolojiler**: Flutter 3.24+, Dart, BLoC Pattern

#### **🔧 Core Modülleri** (`/lib/core/`)
| Modül | Dizin | İşlevi |
|-------|-------|--------|
| **Konfigürasyon** | `/core/config/` | Uygulama sabitleri, Firebase ayarları |
| **Dependency Injection** | `/core/di/` | Servis bağımlılıklarının yönetimi |
| **Ağ İşlemleri** | `/core/network/` | API client, bağlantı durumu kontrolü |
| **Routing** | `/core/routes/` | Sayfa yönlendirme ve navigasyon |
| **Tema** | `/core/theme/` | Material Design 3 tema ayarları |
| **Veritabanı** | `/core/database/` | SQLite yerel veritabanı yönetimi |
| **Yardımcılar** | `/core/utils/` | Bildirim servisi, yardımcı fonksiyonlar |

#### **🎯 Feature Modülleri** (`/lib/features/`)

##### 🔐 **Kimlik Doğrulama** (`/features/auth/`)
- **Amaç**: Kullanıcı girişi, kaydı ve güvenlik
- **Özellikler**: JWT token yönetimi, otomatik giriş, şifre sıfırlama
- **Sayfalar**: Giriş, kayıt sayfaları
- **State Management**: AuthBloc ile durum yönetimi

##### 📚 **Kurs Yönetimi** (`/features/courses/`)
- **Amaç**: Kursların oluşturulması ve yönetimi
- **Özellikler**: Kurs ekleme/düzenleme/silme, haftalık program
- **Sayfalar**: Kurs listesi, kurs ekleme sayfaları
- **State Management**: CoursesBloc ile durum yönetimi

##### 📊 **Devam Takibi** (`/features/attendance/`)
- **Amaç**: Günlük devam durumu işaretleme ve takibi
- **Özellikler**: 4 farklı durum, tarihsel takip, istatistikler
- **Sayfalar**: Devam işaretleme ve analiz sayfaları
- **State Management**: AttendanceBloc ile durum yönetimi

##### 💳 **Abonelik Yönetimi** (`/features/subscription/`)
- **Amaç**: Ücretsiz/Pro plan yönetimi
- **Özellikler**: Plan yükseltme, ödeme işlemleri, özellik kontrolü
- **Sayfalar**: Abonelik planları ve ödeme sayfaları
- **State Management**: SubscriptionBloc ile durum yönetimi

##### 🏠 **Ana Sayfa** (`/features/home/`)
- **Amaç**: Dashboard ve genel bakış
- **Özellikler**: Günlük özet, hızlı erişim, bildirimler

##### 👤 **Profil** (`/features/profile/`)
- **Amaç**: Kullanıcı profili ve ayarlar
- **Özellikler**: Profil düzenleme, ayarlar, çıkış

##### 🚀 **Açılış Ekranı** (`/features/splash/`)
- **Amaç**: Uygulama başlatma ve yükleme
- **Özellikler**: Otomatik giriş kontrolü, veri senkronizasyonu

---

### 🖥️ **Backend (Node.js API Sunucusu)**
**Dizin**: `/backend/`
**Amaç**: RESTful API sunucusu ve iş mantığı
**Teknolojiler**: Node.js 18+, Express.js, PostgreSQL, Prisma ORM

#### **📡 API Katmanları** (`/backend/src/`)

##### 🎮 **Controllers** (`/controllers/`)
- **Amaç**: HTTP isteklerini karşılar ve yanıtları döner
- **Dosyalar**:
  - `authController.js` - Kimlik doğrulama endpoint'leri
  - `courseController.js` - Kurs yönetimi endpoint'leri
  - `attendanceController.js` - Devam takibi endpoint'leri
  - `subscriptionController.js` - Abonelik yönetimi endpoint'leri

##### 🛡️ **Middleware** (`/middleware/`)
- **Amaç**: İstek öncesi güvenlik ve validasyon
- **Dosyalar**:
  - `authMiddleware.js` - JWT token doğrulama
  - `errorHandler.js` - Hata yakalama ve işleme
  - `validationMiddleware.js` - Giriş verisi validasyonu
  - `requestLogger.js` - İstek loglaması
  - `metricsMiddleware.js` - Performans metrikleri

##### 🛣️ **Routes** (`/routes/`)
- **Amaç**: URL yönlendirme ve endpoint tanımlama
- **Dosyalar**:
  - `authRoutes.js` - /auth/* yolları
  - `courseRoutes.js` - /courses/* yolları
  - `attendanceRoutes.js` - /attendance/* yolları
  - `subscriptionRoutes.js` - /subscriptions/* yolları
  - `healthRoutes.js` - /health sağlık kontrolü
  - `queueRoutes.js` - /admin/queues kuyruk yönetimi

##### 🏢 **Services** (`/services/`)
- **Amaç**: İş mantığı ve veritabanı işlemleri
- **Dosyalar**:
  - `authService.js` - Kimlik doğrulama işlemleri
  - `courseService.js` - Kurs CRUD işlemleri
  - `attendanceService.js` - Devam takibi işlemleri
  - `emailService.js` - E-posta gönderimi
  - `queueService.js` - Arka plan görevleri
  - `reportService.js` - Rapor oluşturma

##### 📦 **DTO** (`/dto/`)
- **Amaç**: Veri transfer objelerinin validasyonu
- **Dosyalar**:
  - `authDto.js` - Kimlik doğrulama veri şemaları
  - `courseDto.js` - Kurs veri şemaları

##### ⚙️ **Config** (`/config/`)
- **Amaç**: Uygulama konfigürasyonu
- **Dosyalar**:
  - `index.js` - Ana konfigürasyon
  - `logger.js` - Winston logger ayarları
  - `swagger.js` - API dokümantasyon ayarları

##### 🛢️ **Database** (`/prisma/`)
- **Amaç**: Veritabanı şeması ve migration'lar
- **Dosyalar**:
  - `schema.prisma` - Veritabanı modelleri ve ilişkiler
  - `dev.db` - SQLite geliştirme veritabanı

##### 🧪 **Testing** (`/tests/`)
- **Amaç**: Unit ve integration testleri
- **Yapı**: Jest test framework'ü ile organize edilmiş testler

---

### 🗄️ **Veritabanı Yapısı**

#### **Temel Tablolar**
| Tablo | Amaç | İlişkiler |
|-------|------|-----------|
| **users** | Kullanıcı bilgileri | → courses, attendances, subscription |
| **courses** | Kurs bilgileri | ← users, → attendances, schedules |
| **attendances** | Devam kayıtları | ← users, courses |
| **course_schedules** | Haftalık ders programı | ← courses |
| **subscriptions** | Abonelik durumları | ← users |
| **user_sessions** | Aktif oturumlar | ← users |

#### **Veri Akışı**
```
Mobil App (SQLite) ↔️ API Gateway ↔️ Backend Services ↔️ PostgreSQL
       ↕️                    ↕️              ↕️
  Offline Cache      JWT Auth        Redis Queue
```

---

### 🔧 **Platform Konfigürasyonları**

#### 🤖 **Android** (`/android/`)
- **Amaç**: Android platformu için native konfigürasyon
- **İçerik**: Gradle build scripts, AndroidManifest, launcher icons
- **Özellikler**: Google Play Store deployment ayarları

#### 🍎 **iOS** (`/ios/`)
- **Amaç**: iOS platformu için native konfigürasyon
- **İçerik**: Xcode project, Info.plist, App Store ayarları
- **Özellikler**: Apple Developer deployment ayarları

#### 🌐 **Web** (`/web/`)
- **Amaç**: Progressive Web App (PWA) konfigürasyonu
- **İçerik**: HTML template, manifest.json, service worker
- **Özellikler**: Web deployment için optimize edilmiş ayarlar

#### 🪟 **Windows/Linux/macOS** (`/windows/`, `/linux/`, `/macos/`)
- **Amaç**: Desktop platformları için native konfigürasyon
- **İçerik**: CMake build files, desktop-specific ayarlar

---

### ☁️ **DevOps ve Deployment**

#### 🐳 **Docker** (`/backend/docker-compose.yml`, `/backend/Dockerfile`)
- **Amaç**: Konteynerize edilmiş deployment
- **Servisler**: Backend, PostgreSQL, Redis
- **Özellikler**: Development ve production ortamları

#### ☸️ **Kubernetes** (`/k8s/`)
- **Amaç**: Cloud-native deployment
- **Dosyalar**:
  - `deployment.yaml` - Uygulama deployment'ı
  - `service.yaml` - Load balancer servisi
  - `configmap.yaml` - Konfigürasyon değişkenleri
  - `secrets.yaml` - Hassas bilgiler (encrypted)

#### 📊 **Monitoring** (`/monitoring/`)
- **Amaç**: Sistem performans izleme
- **Araçlar**: Prometheus metrikleri, Grafana dashboard'ları
- **Dosyalar**: `grafana-dashboard.json` - Hazır monitoring paneli

#### ⚡ **Cloudflare** (`/cloudflare/`)
- **Amaç**: CDN, güvenlik ve performans optimizasyonu
- **Workers**: Edge computing ile güvenlik katmanı
- **Dosyalar**: `security-worker.js` - DDoS protection, rate limiting

---

### 📁 **Statik Dosyalar**

#### 🎨 **Assets** (`/assets/`)
- **fonts/**: Özel fontlar (eğer varsa)
- **icons/**: Uygulama iconları ve UI iconları
- **images/**: Resimler ve görseller

---

## 🔄 **Uygulama Akışı**

### 1. **Kullanıcı Girişi**
```
Flutter App → AuthService → JWT Token → Secure Storage
```

### 2. **Offline-First Strateji**
```
User Action → Local SQLite → Background Sync → Cloud PostgreSQL
```

### 3. **Bildirim Sistemi**
```
Course Schedule → Bull.js Queue → Firebase FCM → User Device
```

### 4. **Devam İşaretleme**
```
UI Input → AttendanceBloc → Local Storage → API Sync → Database
```

## 🏛️ **Sistem Mimarisi**

AttendKal projesi, modern mobil uygulama geliştirme prensiplerine uygun olarak katmanlı mimari yapısı ile tasarlanmıştır:

## 📊 **Bileşenler ve Sorumlulukları Özet Tablosu**

| 🎯 Bileşen | 📁 Konum | 🎯 Ana Sorumluluk | 🔧 Teknoloji |
|------------|----------|-------------------|--------------|
| **📱 Mobil UI** | `/lib/features/*/presentation/` | Kullanıcı arayüzü ve etkileşimi | Flutter, Material Design 3 |
| **🧠 State Management** | `/lib/features/*/bloc/` | Uygulama durumu yönetimi | BLoC Pattern |
| **💾 Local Storage** | `/lib/core/database/` | Offline veri depolama | SQLite |
| **🌐 API Client** | `/lib/core/network/` | Backend iletişimi | Dio HTTP Client |
| **🔐 Authentication** | `/lib/features/auth/` | Kullanıcı güvenliği | JWT Tokens |
| **📚 Course Management** | `/lib/features/courses/` | Kurs CRUD işlemleri | Flutter + BLoC |
| **📊 Attendance Tracking** | `/lib/features/attendance/` | Devam takibi | Flutter + Local Storage |
| **💳 Subscription** | `/lib/features/subscription/` | Ödeme yönetimi | Stripe Integration |
| **🖥️ API Server** | `/backend/src/` | RESTful API sunumu | Node.js + Express |
| **🏢 Business Logic** | `/backend/src/services/` | İş kuralları | JavaScript ES6+ |
| **🗄️ Database** | `/backend/prisma/` | Veri persistance | PostgreSQL + Prisma |
| **⚡ Background Jobs** | `/backend/src/services/queueService.js` | Async işlemler | Bull.js + Redis |
| **📧 Notifications** | `/backend/src/services/emailService.js` | E-posta gönderimi | Nodemailer |
| **🔔 Push Notifications** | `/lib/core/utils/notification_service.dart` | Mobil bildirimler | Firebase FCM |
| **🛡️ Security** | `/backend/src/middleware/` | API güvenliği | JWT, Rate Limiting |
| **📈 Monitoring** | `/monitoring/` | Sistem izleme | Prometheus + Grafana |
| **🐳 Deployment** | `/k8s/`, `/backend/docker-compose.yml` | Containerization | Docker + Kubernetes |
| **⚡ CDN/Security** | `/cloudflare/` | Edge computing | Cloudflare Workers |

## 📁 **Detaylı Proje Klasör Yapısı**

### 🗂️ **Ana Dizin Organizasyonu**

```
AttendKal/                      # 📁 Ana proje dizini
│
├── 📱 lib/                     # Flutter mobil uygulaması
├── 🖥️ backend/                 # Node.js API sunucusu  
├── 🤖 android/                 # Android platform konfigürasyonu
├── 🍎 ios/                     # iOS platform konfigürasyonu
├── 🌐 web/                     # Web platform konfigürasyonu
├── 🪟 windows/                 # Windows desktop konfigürasyonu
├── 🐧 linux/                  # Linux desktop konfigürasyonu
├── 🍎 macos/                  # macOS desktop konfigürasyonu
├── 🎨 assets/                  # Statik dosyalar ve medya
├── ☸️ k8s/                     # Kubernetes deployment
├── 📊 monitoring/              # İzleme ve metrikler
├── ⚡ cloudflare/              # CDN ve edge computing
├── 📋 pubspec.yaml             # Flutter proje konfigürasyonu
└── 📖 README.md                # Proje dokümantasyonu
```

### 📱 **Flutter Uygulama Yapısı** (`/lib/`)

#### **🎯 Core Katmanı** - Temel Altyapı
```
lib/core/
├── 📋 config/                  # Uygulama konfigürasyonu
│   ├── app_config.dart         # → Global sabitler, feature flags
│   └── firebase_config.dart    # → Firebase başlatma ayarları
├── 🔌 di/                      # Dependency Injection
│   └── injection_container.dart # → GetIt servis kayıtları
├── 🌐 network/                 # Ağ işlemleri
│   ├── api_client.dart         # → Dio HTTP client + interceptors
│   └── network_info.dart       # → İnternet bağlantı durumu
├── 🧭 routes/                  # Navigasyon yönetimi
│   └── app_router.dart         # → GoRouter sayfa yönlendirme
├── 🎨 theme/                   # UI tema ayarları
│   └── app_theme.dart          # → Material Design 3 tema
├── 💾 database/                # Yerel veritabanı
│   └── database_helper.dart    # → SQLite CRUD işlemleri
└── 🔧 utils/                   # Yardımcı servisler
    └── notification_service.dart # → Push & local bildirimler
```

#### **🎯 Features Katmanı** - İş Modülleri
```
lib/features/
├── 🔐 auth/                    # Kimlik Doğrulama Modülü
│   ├── domain/entities/user.dart       # → User veri modeli
│   └── presentation/
│       ├── bloc/auth_bloc.dart          # → Giriş/çıkış state yönetimi
│       └── pages/
│           ├── login_page.dart          # → Kullanıcı giriş ekranı
│           └── register_page.dart       # → Yeni hesap oluşturma
│
├── 📚 courses/                 # Kurs Yönetimi Modülü
│   ├── domain/entities/course.dart     # → Course veri modeli
│   └── presentation/
│       ├── bloc/courses_bloc.dart       # → Kurs CRUD state yönetimi
│       └── pages/
│           ├── courses_page.dart        # → Kurs listesi görünümü
│           └── add_course_page.dart     # → Yeni kurs ekleme formu
│
├── 📊 attendance/              # Devam Takibi Modülü  
│   ├── domain/entities/attendance.dart # → Attendance veri modeli
│   └── presentation/
│       ├── bloc/attendance_bloc.dart    # → Devam işaretleme state
│       └── pages/attendance_page.dart   # → Devam durumu işaretleme
│
├── 💳 subscription/            # Abonelik Modülü
│   ├── domain/entities/subscription.dart # → Subscription veri modeli
│   └── presentation/
│       ├── bloc/subscription_bloc.dart   # → Plan yönetimi state
│       └── pages/subscription_page.dart  # → Ödeme & plan yükseltme
│
├── 🏠 home/                    # Ana Sayfa Modülü
│   └── presentation/pages/home_page.dart # → Dashboard & günlük özet
│
├── 👤 profile/                 # Profil Modülü
│   └── presentation/pages/profile_page.dart # → Kullanıcı ayarları
│
└── 🚀 splash/                  # Başlangıç Modülü
    └── presentation/pages/splash_page.dart # → Uygulama yükleme ekranı
```

### 🖥️ **Backend API Yapısı** (`/backend/`)

#### **🔧 Kaynak Kod Organizasyonu** (`/backend/src/`)
```
backend/src/
├── 🎮 controllers/             # HTTP Request Handlers
│   ├── authController.js       # → POST /auth/login, /auth/register
│   ├── courseController.js     # → CRUD /api/courses/*
│   ├── attendanceController.js # → CRUD /api/attendance/*
│   └── subscriptionController.js # → /api/subscriptions/* yönetimi
│
├── 🛡️ middleware/              # Request Interceptors
│   ├── authMiddleware.js       # → JWT token doğrulama
│   ├── errorHandler.js         # → Global hata yakalama
│   ├── validationMiddleware.js # → Request body validasyon
│   ├── requestLogger.js        # → Morgan HTTP loglaması
│   └── metricsMiddleware.js    # → Prometheus metrik toplama
│
├── 🛣️ routes/                  # URL Route Tanımları
│   ├── authRoutes.js          # → /api/auth/* endpoint'leri
│   ├── courseRoutes.js        # → /api/courses/* endpoint'leri
│   ├── attendanceRoutes.js    # → /api/attendance/* endpoint'leri
│   ├── subscriptionRoutes.js  # → /api/subscriptions/* endpoint'leri
│   ├── healthRoutes.js        # → /health sistem durumu
│   └── queueRoutes.js         # → /admin/queues kuyruk yönetimi
│
├── 🏢 services/                # Business Logic Katmanı
│   ├── authService.js         # → JWT oluşturma, şifre hashleme
│   ├── courseService.js       # → Kurs CRUD business logic
│   ├── attendanceService.js   # → Devam takibi iş mantığı
│   ├── emailService.js        # → Nodemailer e-posta gönderimi
│   ├── queueService.js        # → Bull.js arka plan görevleri
│   └── reportService.js       # → PDF/Excel rapor oluşturma
│
├── 📦 dto/                     # Data Transfer Objects
│   ├── authDto.js             # → Giriş/kayıt validasyon şemaları
│   └── courseDto.js           # → Kurs veri validasyon şemaları
│
├── ⚙️ config/                  # Uygulama Konfigürasyonu
│   ├── index.js               # → Environment değişkenleri
│   ├── logger.js              # → Winston logging ayarları
│   └── swagger.js             # → API dokümantasyon konfigürasyonu
│
├── 🔧 utils/                   # Yardımcı Fonksiyonlar
│   └── prisma.js              # → Veritabanı client başlatma
│
└── 🚀 server.js                # → Express.js uygulama giriş noktası
```

#### **🗄️ Veritabanı Katmanı** (`/backend/prisma/`)
```
backend/prisma/
├── 📋 schema.prisma            # → Veritabanı modelleri & ilişkiler
├── 💾 dev.db                  # → SQLite development veritabanı
└── 📈 migrations/              # → Otomatik veritabanı sürüm kontrolü
    ├── 001_initial_schema.sql
    ├── 002_add_subscriptions.sql
    └── 003_add_course_schedules.sql
```

#### **🧪 Test Katmanı** (`/backend/tests/`)
```
backend/tests/
├── 🛠️ setup.js                # → Jest test ortamı konfigürasyonu
├── 🔬 unit/                    # → Unit testler
│   └── services/
│       ├── authService.test.js
│       ├── courseService.test.js
│       └── attendanceService.test.js
└── 🔗 integration/             # → API endpoint testleri
    ├── auth.test.js
    ├── courses.test.js
    └── attendance.test.js
```

### 📱 **Platform Konfigürasyon Detayları**

#### **🤖 Android Yapısı** (`/android/`)
```
android/
├── 🛠️ app/
│   ├── build.gradle.kts       # → Gradle build konfigürasyonu
│   └── src/main/
│       ├── AndroidManifest.xml # → App izinleri & aktiviteler
│       ├── kotlin/MainActivity.kt # → Android native bridge
│       └── res/                # → App iconları & kaynaklari
├── ⚙️ gradle/                  # → Gradle wrapper konfigürasyonu
└── 📋 gradle.properties        # → Build özelleştirmeleri
```

#### **🍎 iOS Yapısı** (`/ios/`)
```
ios/
├── 🛠️ Runner/
│   ├── Info.plist            # → iOS app konfigürasyonu & izinler
│   ├── AppDelegate.swift     # → iOS uygulama lifecycle
│   └── Assets.xcassets/      # → App iconları & launch screen
├── 📦 Pods/                   # → CocoaPods dependencies
└── 🏗️ Runner.xcodeproj/       # → Xcode proje konfigürasyonu
```

#### **🌐 Web Yapısı** (`/web/`)
```
web/
├── 📄 index.html              # → HTML template
├── 📋 manifest.json           # → Progressive Web App ayarları
├── 🎨 favicon.png             # → Web site ikonu
└── 📱 icons/                  # → PWA app iconları
```

### ☁️ **DevOps Infrastructure**

#### **🐳 Container Yapısı** (`/backend/`)
```
backend/
├── 🐳 Dockerfile              # → Multi-stage Docker build
│   ├── Stage 1: Dependencies  # → npm install optimization
│   ├── Stage 2: Build         # → Prisma generate
│   └── Stage 3: Production    # → Minimal runtime image
├── 🏗️ docker-compose.yml      # → Development ortamı
│   ├── 🖥️ backend service      # → Node.js API container
│   ├── 🗄️ postgres service     # → PostgreSQL database
│   └── 🔴 redis service        # → Redis cache & sessions
└── 🚫 .dockerignore           # → Build context optimizasyonu
```

#### **☸️ Kubernetes Cluster** (`/k8s/`)
```
k8s/
├── 🏷️ namespace.yaml          # → Isolated Kubernetes namespace
├── 🚀 deployment.yaml         # → Backend app deployment
│   ├── Replica management     # → High availability setup
│   ├── Rolling updates        # → Zero-downtime deployment
│   └── Resource limits        # → CPU & memory constraints
├── ⚖️ service.yaml            # → Load balancer konfigürasyonu
├── 📋 configmap.yaml          # → Non-sensitive konfigürasyon
└── 🔐 secrets.yaml            # → Encrypted sensitive data
```

#### **📊 Monitoring Stack** (`/monitoring/`)
```
monitoring/
├── 🔍 prometheus.yml          # → Metrik toplama konfigürasyonu
│   ├── Scrape configs         # → API endpoint monitoring
│   ├── Alert rules            # → Performance threshold alerts
│   └── Storage retention      # → Data lifecycle management
└── 📈 grafana-dashboard.json  # → Pre-built görselleştirme paneli
    ├── API response times     # → HTTP endpoint performance
    ├── Database connections   # → PostgreSQL connection pool
    ├── Memory & CPU usage     # → System resource utilization
    └── Error rates           # → Application error tracking
```

#### **⚡ Edge Computing** (`/cloudflare/`)
```
cloudflare/
├── 👷 workers/
│   └── security-worker.js     # → Edge security katmanı
│       ├── DDoS protection    # → Automated threat blocking
│       ├── Rate limiting      # → API abuse prevention
│       ├── Geo-blocking       # → Location-based access control
│       └── Bot detection      # → Automated traffic filtering
└── 📋 page-rules.json         # → CDN caching konfigürasyonu
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

# Feature Flags & Maintenance Mode
SUBSCRIPTION_ENABLED=true
SUBSCRIPTION_MAINTENANCE=false
ANALYTICS_ENABLED=true
NOTIFICATIONS_ENABLED=true

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

## 🔧 **Maintenance Mode & Feature Flags**

### **Feature Control**
AttendKal supports feature flags to enable/disable specific functionality during development or maintenance:

#### **Backend Feature Flags**
```env
# Feature toggles
SUBSCRIPTION_ENABLED=true          # Enable/disable subscription features
SUBSCRIPTION_MAINTENANCE=false     # Maintenance mode for subscription service
ANALYTICS_ENABLED=true            # Enable/disable analytics features
NOTIFICATIONS_ENABLED=true        # Enable/disable notification system
```

#### **Flutter Feature Flags**
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const bool subscriptionEnabled = false; // Maintenance mode
  static const bool analyticsEnabled = true;
  static const bool notificationsEnabled = true;
}
```

### **Maintenance Mode Implementation**

#### **Backend Maintenance**
When `SUBSCRIPTION_MAINTENANCE=true`, all subscription routes return 503:
```json
{
  "success": false,
  "message": "Abonelik servisi geçici bakımda.",
  "error": "SERVICE_MAINTENANCE",
  "retryAfter": 3600
}
```

#### **Flutter Maintenance**
When `subscriptionEnabled=false`, subscription page shows maintenance UI:
```dart
// Maintenance mode placeholder
return Center(
  child: Column(
    children: [
      Icon(Icons.construction, color: Colors.orange),
      Text('Abonelik bölümü şu anda bakımda.'),
    ],
  ),
);
```

### **Switching Between Modes**

#### **Enable Subscription (Production Ready)**
```bash
# Backend
echo "SUBSCRIPTION_MAINTENANCE=false" >> .env

# Flutter 
# Set subscriptionEnabled = true in app_config.dart
```

#### **Disable Subscription (Maintenance)**
```bash
# Backend
echo "SUBSCRIPTION_MAINTENANCE=true" >> .env

# Flutter
# Set subscriptionEnabled = false in app_config.dart
```

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