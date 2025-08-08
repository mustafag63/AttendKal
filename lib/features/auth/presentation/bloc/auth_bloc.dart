import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/routes/app_router.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthInitialEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const AuthRegisterEvent(
      this.name, this.email, this.password, this.confirmPassword);

  @override
  List<Object> get props => [name, email, password, confirmPassword];
}

class AuthLogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(AuthInitial()) {
    on<AuthInitialEvent>(_onInitial);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onInitial(
      AuthInitialEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (_apiService.isAuthenticated) {
        final user = await _apiService.getCurrentUser();
        emit(AuthAuthenticated(user));
        AppRouter.refresh();
      } else {
        emit(AuthUnauthenticated());
        AppRouter.refresh();
      }
    } catch (e) {
      emit(AuthUnauthenticated());
      AppRouter.refresh();
    }
  }

  Future<void> _onCheckStatus(
      AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    try {
      if (_apiService.isAuthenticated) {
        final user = await _apiService.getCurrentUser();
        emit(AuthAuthenticated(user));
        AppRouter.refresh();
      } else {
        emit(AuthUnauthenticated());
        AppRouter.refresh();
      }
    } catch (e) {
      emit(AuthUnauthenticated());
      AppRouter.refresh();
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    print('🔐 Login attempt for: ${event.email}');
    emit(AuthLoading());
    try {
      final result = await _apiService.login(event.email, event.password);
      print('✅ Login successful for: ${event.email}');
      print('📱 User data: ${result['user']}');
      emit(AuthAuthenticated(result['user']));
      AppRouter.refresh();
    } on ApiError catch (e) {
      print('❌ Login failed with ApiError: ${e.message}');
      emit(AuthError(e.message ?? 'Login failed'));
      AppRouter.refresh();
    } catch (e) {
      print('❌ Login failed with unexpected error: $e');
      emit(AuthError('An unexpected error occurred'));
      AppRouter.refresh();
    }
  }

  Future<void> _onRegister(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (event.password != event.confirmPassword) {
        emit(AuthError('Passwords do not match'));
        AppRouter.refresh();
        return;
      }

      final result = await _apiService.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(result['user']));
      AppRouter.refresh();
    } on ApiError catch (e) {
      emit(AuthError(e.message ?? 'Registration failed'));
      AppRouter.refresh();
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
      AppRouter.refresh();
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      emit(AuthUnauthenticated());
      AppRouter.refresh();
    }
  }
}
