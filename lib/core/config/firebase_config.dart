import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  // Firebase Options for different platforms
  static const FirebaseOptions androidOptions = FirebaseOptions(
    apiKey: 'AIzaSyB7PsZOae00pONLfXVD2nrUaH4pwtvyTmk',
    appId: '1:48926672959:android:6d83f0d30b197eddd8908a',
    messagingSenderId: '48926672959',
    projectId: 'attendkal',
    storageBucket: 'attendkal.firebasestorage.app',
  );

  static const FirebaseOptions iosOptions = FirebaseOptions(
    apiKey: 'AIzaSyDnS12v3PLZTiarmExai1txrFhfxcf6YmM',
    appId: '1:48926672959:ios:89a83d4907d2e5bfd8908a',
    messagingSenderId: '48926672959',
    projectId: 'attendkal',
    storageBucket: 'attendkal.firebasestorage.app',
    iosClientId: '48926672959.apps.googleusercontent.com',
    iosBundleId: 'com.attendkal.attendkal',
  );

  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: 'AIzaSyB7PsZOae00pONLfXVD2nrUaH4pwtvyTmk',
    appId: '1:48926672959:web:89a83d4907d2e5bfd8908a',
    messagingSenderId: '48926672959',
    projectId: 'attendkal',
    storageBucket: 'attendkal.firebasestorage.app',
    authDomain: 'attendkal.firebaseapp.com',
  );

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String attendanceCollection = 'attendance';
  static const String subscriptionsCollection = 'subscriptions';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';

  // Firebase Auth Settings
  static const bool enablePersistence = true;
  static const bool enableNetworkActivityIndicator = true;

  // Firestore Settings
  static const bool enableOfflinePersistence = true;
  static const bool enableNetworkActivityIndicatorForFirestore = true;

  // Get platform-specific Firebase options
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return webOptions;
    }
    switch (Platform.operatingSystem) {
      case 'android':
        return androidOptions;
      case 'ios':
        return iosOptions;
      default:
        throw UnsupportedError(
          'Firebase options have not been configured for this platform.',
        );
    }
  }

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: currentPlatform,
    );

    // Configure Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: enableOfflinePersistence,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Configure Firebase Auth
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Get Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
}
