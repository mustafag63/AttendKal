import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/local/db.dart';
import 'dio_client.dart';

class AttendanceApiService {
  final DioClient _dioClient;

  AttendanceApiService(this._dioClient);

  /// Mark attendance for a session via backend API
  Future<Map<String, dynamic>> markAttendance({
    required String sessionId,
    required AttendanceStatus status,
    String? note,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/attendance/$sessionId',
        data: {'status': _mapStatusToBackend(status), 'note': note},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to mark attendance: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in markAttendance: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Session not found.');
      } else if ((e.response?.statusCode ?? 0) >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to mark attendance: ${e.message}');
      }
    } catch (e) {
      debugPrint('General error in markAttendance: $e');
      throw Exception('Failed to mark attendance: $e');
    }
  }

  /// Get attendance details for a session
  Future<Map<String, dynamic>> getAttendance(String sessionId) async {
    try {
      final response = await _dioClient.dio.get('/attendance/$sessionId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get attendance: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getAttendance: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Session not found.');
      } else {
        throw Exception('Failed to get attendance: ${e.message}');
      }
    } catch (e) {
      debugPrint('General error in getAttendance: $e');
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Send FCM token to backend
  Future<bool> sendFCMToken({
    required String userId,
    required String fcmToken,
    String? deviceId,
    String? platform,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/users/$userId/fcm-token',
        data: {
          'fcmToken': fcmToken,
          'deviceId': deviceId,
          'platform': platform ?? 'mobile',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('FCM token sent successfully for user: $userId');
        return true;
      } else {
        debugPrint('Failed to send FCM token: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioException in sendFCMToken: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unknown error in sendFCMToken: $e');
      return false;
    }
  }

  /// Remove FCM token from backend (on logout)
  Future<bool> removeFCMToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final response = await _dioClient.dio.delete(
        '/users/$userId/fcm-token',
        data: {'fcmToken': fcmToken},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('FCM token removed successfully for user: $userId');
        return true;
      } else {
        debugPrint('Failed to remove FCM token: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioException in removeFCMToken: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unknown error in removeFCMToken: $e');
      return false;
    }
  }

  Future<void> syncNotificationAction({
    required String reminderId,
    required NotificationActionType actionType,
    required String sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dioClient.dio.post(
        '/attendance/notification-action',
        data: {
          'reminderId': reminderId,
          'actionType': _mapActionTypeToBackend(actionType),
          'sessionId': sessionId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'metadata': metadata,
        },
      );
    } on DioException catch (e) {
      debugPrint('DioException in syncNotificationAction: ${e.message}');
      // Don't throw - notification actions are not critical for backend sync
      // They're mainly for local analytics and future features
    } catch (e) {
      debugPrint('General error in syncNotificationAction: $e');
      // Don't throw - notification actions are not critical for backend sync
    }
  }

  /// Map local AttendanceStatus to backend format
  String _mapStatusToBackend(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.absent:
        return 'ABSENT';
      case AttendanceStatus.late:
        return 'LATE';
      case AttendanceStatus.excused:
        return 'EXCUSED';
    }
  }

  /// Map NotificationActionType to backend format
  String _mapActionTypeToBackend(NotificationActionType actionType) {
    switch (actionType) {
      case NotificationActionType.attended:
        return 'attended';
      case NotificationActionType.missed:
        return 'missed';
      case NotificationActionType.snooze10:
        return 'snooze10';
      case NotificationActionType.snooze30:
        return 'snooze30';
      case NotificationActionType.snooze2h:
        return 'snooze2h';
    }
  }
}
