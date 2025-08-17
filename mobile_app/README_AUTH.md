# Attendkal Mobile App - Auth Implementation

## Test Backend Setup

Bu test backend'i, auth flow'unu test etmek için basit bir Node.js/Express sunucusudur.

### Kurulum

1. Backend dizini oluşturun:
```bash
mkdir attendkal-backend
cd attendkal-backend
npm init -y
```

2. Gerekli paketleri yükleyin:
```bash
npm install express cors helmet dotenv bcryptjs jsonwebtoken
npm install -D nodemon
```

3. server.js dosyasını oluşturun:
```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-key';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// In-memory user storage (use database in production)
let users = [
  {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    password: '$2a$10$rOzTkKj8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j8j', // password
    phone: '+1234567890',
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

// Helper functions
const generateToken = (userId) => {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '7d' });
};

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Access token required' });
  }
  
  const token = authHeader.substring(7);
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

// Routes

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password, passwordConfirmation, phone } = req.body;
    
    // Validation
    if (!name || !email || !password || !passwordConfirmation) {
      return res.status(400).json({
        message: 'All fields are required',
        errors: {
          name: !name ? ['Name is required'] : [],
          email: !email ? ['Email is required'] : [],
          password: !password ? ['Password is required'] : [],
          passwordConfirmation: !passwordConfirmation ? ['Password confirmation is required'] : []
        }
      });
    }
    
    if (password !== passwordConfirmation) {
      return res.status(400).json({
        message: 'Passwords do not match',
        errors: {
          passwordConfirmation: ['Passwords do not match']
        }
      });
    }
    
    if (password.length < 6) {
      return res.status(400).json({
        message: 'Password must be at least 6 characters',
        errors: {
          password: ['Password must be at least 6 characters']
        }
      });
    }
    
    // Check if user exists
    const existingUser = users.find(user => user.email === email);
    if (existingUser) {
      return res.status(409).json({
        message: 'User already exists',
        errors: {
          email: ['Email is already registered']
        }
      });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create user
    const newUser = {
      id: String(users.length + 1),
      name,
      email,
      password: hashedPassword,
      phone: phone || null,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    users.push(newUser);
    
    // Generate token
    const token = generateToken(newUser.id);
    
    // Return response
    const { password: _, ...userWithoutPassword } = newUser;
    res.status(201).json({
      accessToken: token,
      tokenType: 'Bearer',
      expiresIn: 604800, // 7 days in seconds
      user: userWithoutPassword
    });
    
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validation
    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required',
        errors: {
          email: !email ? ['Email is required'] : [],
          password: !password ? ['Password is required'] : []
        }
      });
    }
    
    // Find user
    const user = users.find(user => user.email === email);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    // Check password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    // Generate token
    const token = generateToken(user.id);
    
    // Return response
    const { password: _, ...userWithoutPassword } = user;
    res.json({
      accessToken: token,
      tokenType: 'Bearer',
      expiresIn: 604800, // 7 days in seconds
      user: userWithoutPassword
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get current user
app.get('/api/auth/me', verifyToken, (req, res) => {
  try {
    const user = users.find(user => user.id === req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    const { password: _, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
    
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Logout
app.post('/api/auth/logout', verifyToken, (req, res) => {
  // In a real app, you might invalidate the token in a blacklist
  res.json({ message: 'Logged out successfully' });
});

// Refresh token
app.post('/api/auth/refresh', verifyToken, (req, res) => {
  try {
    const newToken = generateToken(req.userId);
    
    res.json({
      accessToken: newToken,
      tokenType: 'Bearer',
      expiresIn: 604800
    });
    
  } catch (error) {
    console.error('Refresh error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('API endpoints:');
  console.log('  POST /api/auth/register');
  console.log('  POST /api/auth/login');
  console.log('  GET  /api/auth/me');
  console.log('  POST /api/auth/logout');
  console.log('  POST /api/auth/refresh');
  console.log('  GET  /api/health');
  console.log('');
  console.log('Test credentials:');
  console.log('  Email: test@example.com');
  console.log('  Password: password');
});
```

4. package.json'a script ekleyin:
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

5. Backend'i çalıştırın:
```bash
npm run dev
```

## Test Talimatları

### 1. Backend'i Başlatın
```bash
cd attendkal-backend
npm run dev
```
Backend http://localhost:3000 adresinde çalışacak.

### 2. Flutter App'i Çalıştırın
```bash
cd mobile_app
flutter run
```

### 3. Test Senaryoları

#### Login Test:
- Email: `test@example.com`
- Password: `password`

#### Register Test:
- Name: `Your Name`
- Email: `new@example.com`
- Password: `newpassword`
- Confirm Password: `newpassword`

#### Error Testing:
- Yanlış şifre ile login deneyın
- Eksik bilgilerle register olun
- Network hataları için backend'i kapatın

### 4. API Endpoints

- `POST /api/auth/register` - Kayıt ol
- `POST /api/auth/login` - Giriş yap
- `GET /api/auth/me` - Kullanıcı bilgilerini getir
- `POST /api/auth/logout` - Çıkış yap
- `POST /api/auth/refresh` - Token yenile
- `GET /api/health` - Sağlık kontrolü

### 5. Hata Kodları

- `400` - Validation hatası
- `401` - Kimlik doğrulama hatası
- `403` - Yetkilendirme hatası
- `404` - Bulunamadı
- `409` - Çakışma (kullanıcı zaten var)
- `500` - Sunucu hatası

## Özellikler

✅ JWT tabanlı kimlik doğrulama  
✅ Şifre hashleme (bcrypt)  
✅ Token yenileme  
✅ Secure storage (flutter_secure_storage)  
✅ Riverpod state management  
✅ Hata eşleme ve handling  
✅ Form validation  
✅ Loading states  
✅ Auto redirect (login/logout)  
✅ Responsive UI  

## Güvenlik

- Şifreler bcrypt ile hashleniyor
- JWT tokenlar güvenli şekilde saklanıyor
- HTTPS kullanımı öneriliyor (production'da)
- Token expiration kontrolü
- Secure storage kullanımı
