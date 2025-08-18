# Push Notifications Setup Guide

This guide explains how to set up Firebase Cloud Messaging (FCM) push notifications for the AttendKal app.

## Overview

The push notification system consists of:
- **Frontend (Flutter)**: Firebase Messaging SDK for receiving notifications
- **Backend (Node.js)**: Firebase Admin SDK for sending notifications
- **Database**: FCM token storage and management

## Features Implemented

### ✅ Frontend (Mobile App)
- Firebase Core and Messaging integration
- FCM token generation and storage
- Foreground and background message handling
- Local notification display for Android
- Notification action handling (tap to open app)
- Topic subscriptions for targeted messaging
- Token refresh handling
- Integration with existing local notification system

### ✅ Backend (API Server)
- FCM token management endpoints
- Firebase Admin SDK service
- Push notification sending capabilities
- User-specific and topic-based messaging
- Token cleanup and maintenance

### ✅ Database Schema
- UserDeviceToken model for FCM token storage
- Token lifecycle management (active/inactive)
- Device information tracking

## Setup Instructions

### 1. Firebase Project Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one
   - Enable Cloud Messaging

2. **Add Android App**:
   - Register Android app with package name: `com.attendkal.mobile_app`
   - Download `google-services.json`
   - Place in `mobile_app/android/app/` directory

3. **Add iOS App**:
   - Register iOS app with bundle ID: `com.attendkal.mobileApp`
   - Download `GoogleService-Info.plist`
   - Add to iOS project in Xcode

4. **Get Server Key**:
   - Go to Project Settings → Service Accounts
   - Generate new private key (JSON)
   - Save securely for backend configuration

### 2. Frontend Configuration

1. **Update Firebase Options**:
   ```bash
   cd mobile_app
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

2. **Update Package Bundle IDs**:
   - Android: `com.attendkal.mobile_app` in `android/app/build.gradle`
   - iOS: `com.attendkal.mobileApp` in `ios/Runner.xcodeproj`

3. **iOS Configuration**:
   - Enable Push Notifications capability in Xcode
   - Add Background Modes capability (Background App Refresh, Remote notifications)
   - Upload APNs certificates to Firebase Console

### 3. Backend Configuration

1. **Install Dependencies**:
   ```bash
   cd backend
   npm install firebase-admin
   ```

2. **Environment Variables**:
   ```env
   FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}
   ```

3. **Database Migration**:
   ```bash
   npm run prisma:generate
   npm run prisma:migrate
   ```

### 4. Testing Setup

1. **Test FCM Token Generation**:
   ```dart
   // In your Flutter app
   final fcmToken = await FirebaseMessaging.instance.getToken();
   print('FCM Token: $fcmToken');
   ```

2. **Test Backend Notification**:
   ```bash
   curl -X POST http://localhost:3000/api/users/USER_ID/fcm-token \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -d '{"fcmToken":"YOUR_FCM_TOKEN","platform":"mobile"}'
   ```

## API Endpoints

### FCM Token Management

```http
POST   /api/users/:userId/fcm-token      # Store FCM token
DELETE /api/users/:userId/fcm-token      # Remove FCM token
GET    /api/users/:userId/fcm-tokens     # Get user's tokens
POST   /api/users/fcm-tokens/cleanup     # Cleanup inactive tokens
```

### Notification Sending (Backend Service)

```typescript
// Send to specific user
await FirebaseAdminService.getInstance().sendNotificationToUser(
  userId,
  'Title',
  'Body',
  { type: 'reminder', targetId: 'reminder-id' }
);

// Send attendance reminder
await FirebaseAdminService.getInstance().sendAttendanceReminder(
  userId,
  sessionId,
  'Course Title',
  'morning'
);
```

## Integration Points

### 1. User Authentication
- FCM token is sent to backend after successful login
- Token is removed from backend on logout
- Token refresh is handled automatically

### 2. Attendance System
- Attendance reminders sent via push notifications
- Notification actions trigger attendance marking
- Backend sync for notification analytics

### 3. Reminder System
- Custom reminders sent via push notifications
- Integration with existing local notification system
- Snooze functionality preserved

## Message Types

### 1. Attendance Reminders
```json
{
  "title": "📚 Ders yaklaşıyor",
  "body": "Matematik dersiniz 30 dakika içinde başlayacak.",
  "data": {
    "type": "attendance",
    "sessionId": "session-uuid",
    "reminderType": "preStart"
  }
}
```

### 2. Custom Reminders
```json
{
  "title": "Hatırlatıcı",
  "body": "Ödev teslim tarihi yaklaşıyor",
  "data": {
    "type": "reminder",
    "reminderId": "reminder-uuid",
    "targetId": "reminder-uuid"
  }
}
```

### 3. General Notifications
```json
{
  "title": "AttendKal",
  "body": "Yeni özellikler kullanılabilir!",
  "data": {
    "type": "general",
    "targetId": "home"
  }
}
```

## Topic Subscriptions

- `attendkal_general`: App-wide announcements
- `user_{userId}`: User-specific notifications
- `course_{courseId}`: Course-specific updates (future)

## Security Considerations

1. **Token Protection**:
   - FCM tokens are stored securely in database
   - Tokens are marked inactive on logout
   - Old tokens are automatically cleaned up

2. **Authentication**:
   - All FCM token endpoints require authentication
   - User can only manage their own tokens
   - Backend validates user permissions

3. **Data Privacy**:
   - Notification data is minimal and non-sensitive
   - Personal information is not sent in push payload
   - App fetches details on notification tap

## Troubleshooting

### Common Issues

1. **No FCM Token Generated**:
   - Check Firebase project configuration
   - Verify google-services.json placement
   - Check app permissions

2. **Notifications Not Received**:
   - Verify FCM token is sent to backend
   - Check Firebase Console message logs
   - Verify device network connectivity

3. **iOS Notifications Issues**:
   - Check APNs certificates
   - Verify app capabilities
   - Check iOS notification permissions

### Debug Commands

```bash
# Check FCM token in app logs
flutter logs | grep "FCM Token"

# Test backend notification sending
curl -X POST http://localhost:3000/api/test/notification

# Check database for stored tokens
npx prisma studio
```

## Future Enhancements

1. **Rich Notifications**:
   - Images and actions in notifications
   - Custom notification sounds
   - Notification categories

2. **Advanced Targeting**:
   - Course-based subscriptions
   - Time-based scheduling
   - Location-based notifications

3. **Analytics**:
   - Notification delivery tracking
   - Open rate analytics
   - User engagement metrics

4. **Web Push**:
   - Browser push notifications
   - Progressive Web App support

## Files Modified/Created

### Mobile App (Flutter)
- `lib/services/firebase_messaging_service.dart` - Main FCM service
- `lib/providers/firebase_messaging_providers.dart` - Riverpod providers
- `lib/firebase_options.dart` - Firebase configuration
- `pubspec.yaml` - Added Firebase dependencies
- `main.dart` - Firebase initialization

### Backend (Node.js)
- `src/services/firebase-admin.service.ts` - Firebase Admin service
- `src/modules/users/controller.ts` - FCM token endpoints
- `src/modules/users/routes.ts` - FCM token routes
- `prisma/schema.prisma` - UserDeviceToken model
- `package.json` - Added firebase-admin dependency

### Configuration Files
- `google-services.json` (Android) - Place in `android/app/`
- `GoogleService-Info.plist` (iOS) - Add to iOS project
- Service account key JSON - Set in environment variable
