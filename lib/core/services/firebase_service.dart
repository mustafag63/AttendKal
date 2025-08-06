import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

// Custom exceptions for clarity
class AuthError implements Exception {
  final String code;
  final String? message;
  AuthError({required this.code, this.message});
  @override
  String toString() => 'AuthError($code): $message';
}

class FirestoreError implements Exception {
  final String code;
  final String? message;
  FirestoreError({required this.code, this.message});
  @override
  String toString() => 'FirestoreError($code): $message';
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal() {
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Authentication methods ---
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError(code: e.code, message: e.message);
    } catch (e) {
      throw AuthError(code: 'unknown', message: e.toString());
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError(code: e.code, message: e.message);
    } catch (e) {
      throw AuthError(code: 'unknown', message: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthError(code: 'sign_out_failed', message: e.toString());
    }
  }

  User get currentUser {
    final user = _auth.currentUser;
    if (user == null)
      throw AuthError(code: 'no_user', message: 'No user logged in');
    return user;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Firestore methods ---
  Future<void> addUser(Map<String, dynamic> userData) async {
    final uid = currentUser.uid;
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .set(userData);
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    final uid = currentUser.uid;
    try {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(uid)
          .update(userData);
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  // --- Course methods ---
  Future<void> addCourse(Map<String, dynamic> courseData) async {
    final uid = currentUser.uid;
    try {
      await _firestore.collection(FirebaseConfig.coursesCollection).add({
        ...courseData,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Future<void> updateCourse(
      String courseId, Map<String, dynamic> courseData) async {
    try {
      await _firestore
          .collection(FirebaseConfig.coursesCollection)
          .doc(courseId)
          .update({
        ...courseData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.coursesCollection)
          .doc(courseId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Stream<QuerySnapshot> getUserCourses({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null)
      return Stream.error(AuthError(code: 'no_user', message: null));
    return _firestore
        .collection(FirebaseConfig.coursesCollection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // --- Attendance methods ---
  Future<void> addAttendance(Map<String, dynamic> attendanceData) async {
    final uid = currentUser.uid;
    try {
      await _firestore.collection(FirebaseConfig.attendanceCollection).add({
        ...attendanceData,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Stream<QuerySnapshot> getCourseAttendance(String courseId, {int limit = 50}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null)
      return Stream.error(AuthError(code: 'no_user', message: null));
    return _firestore
        .collection(FirebaseConfig.attendanceCollection)
        .where('userId', isEqualTo: uid)
        .where('courseId', isEqualTo: courseId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots();
  }

  // --- Subscription methods ---
  Future<void> updateSubscription(Map<String, dynamic> subscriptionData) async {
    final uid = currentUser.uid;
    try {
      await _firestore
          .collection(FirebaseConfig.subscriptionsCollection)
          .doc(uid)
          .set(subscriptionData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Future<DocumentSnapshot> getSubscription() async {
    final uid = currentUser.uid;
    try {
      return await _firestore
          .collection(FirebaseConfig.subscriptionsCollection)
          .doc(uid)
          .get();
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  // --- Report methods ---
  Future<void> generateReport(Map<String, dynamic> reportData) async {
    final uid = currentUser.uid;
    try {
      await _firestore.collection(FirebaseConfig.reportsCollection).add({
        ...reportData,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreError(code: e.code, message: e.message);
    }
  }

  Stream<QuerySnapshot> getUserReports({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null)
      return Stream.error(AuthError(code: 'no_user', message: null));
    return _firestore
        .collection(FirebaseConfig.reportsCollection)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }
}
