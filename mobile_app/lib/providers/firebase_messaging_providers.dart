import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_messaging_service.dart';

// Firebase messaging service provider
final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>(
  (ref) => FirebaseMessagingService(),
);

// FCM token provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messagingService = ref.watch(firebaseMessagingServiceProvider);
  return await messagingService.getStoredFCMToken() ??
      messagingService.fcmToken;
});

// FCM token refresh notifier
class FCMTokenNotifier extends StateNotifier<AsyncValue<String?>> {
  final FirebaseMessagingService _messagingService;

  FCMTokenNotifier(this._messagingService) : super(const AsyncValue.loading()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final token =
          await _messagingService.getStoredFCMToken() ??
          _messagingService.fcmToken;
      state = AsyncValue.data(token);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshToken() async {
    state = const AsyncValue.loading();
    await _loadToken();
  }

  Future<bool> sendTokenToBackend(String userId, String? authToken) async {
    try {
      final success = await _messagingService.sendTokenToBackend(
        userId,
        authToken,
      );
      if (success) {
        await refreshToken();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> subscribeToUserTopics(String userId) async {
    await _messagingService.subscribeToUserTopics(userId);
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    await _messagingService.unsubscribeFromUserTopics(userId);
  }
}

final fcmTokenNotifierProvider =
    StateNotifierProvider<FCMTokenNotifier, AsyncValue<String?>>((ref) {
      final messagingService = ref.watch(firebaseMessagingServiceProvider);
      return FCMTokenNotifier(messagingService);
    });
