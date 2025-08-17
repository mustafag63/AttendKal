import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/dio_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user.dart';
import '../data/models/auth_models.dart';
import '../core/error/exceptions.dart';

// DIO Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient);
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

// Auth State Classes
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthAuthenticated && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError(this.message, {this.code});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.message == message && other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, code);
}

// Auth State Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = const AuthLoading();

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _authRepository.login(loginRequest);
      final user = User.fromJson(authResponse.user);
      state = AuthAuthenticated(user);
    } catch (e) {
      String message = 'Login failed';
      String? code;

      if (e is AppException) {
        message = e.message;
        code = e.code;
      }

      state = AuthError(message, code: code);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    state = const AuthLoading();

    try {
      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final authResponse = await _authRepository.register(registerRequest);
      final user = User.fromJson(authResponse.user);
      state = AuthAuthenticated(user);
    } catch (e) {
      String message = 'Registration failed';
      String? code;

      if (e is AppException) {
        message = e.message;
        code = e.code;
      }

      state = AuthError(message, code: code);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();

    try {
      await _authRepository.logout();
      state = const AuthUnauthenticated();
    } catch (e) {
      // Even if logout fails, set state to unauthenticated
      state = const AuthUnauthenticated();
    }
  }

  Future<void> refreshUser() async {
    if (state is! AuthAuthenticated) return;

    try {
      final user = await _authRepository.getCurrentUser();
      state = AuthAuthenticated(user);
    } catch (e) {
      // If refresh fails, user might be logged out
      state = const AuthUnauthenticated();
    }
  }
}
