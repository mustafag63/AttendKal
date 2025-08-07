import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_client.dart';

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
  final ApiClient _apiClient;

  AuthBloc({
    required ApiClient apiClient,
    dynamic loginUseCase,
    dynamic registerUseCase,
    dynamic logoutUseCase,
  })  : _apiClient = apiClient,
        super(AuthInitial()) {
    on<AuthInitialEvent>(_onInitial);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
  }

  void _onInitial(AuthInitialEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Check if user is already logged in
    final response = await _apiClient.getCurrentUser();
    if (response.success && response.data != null) {
      emit(AuthAuthenticated(response.data!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onCheckStatus(
      AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _apiClient.getCurrentUser();
    if (response.success && response.data != null) {
      emit(AuthAuthenticated(response.data!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiClient.login(
        email: event.email,
        password: event.password,
      );

      if (response.success && response.data != null) {
        emit(AuthAuthenticated(response.data!));
      } else {
        emit(AuthError(response.error ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiClient.register(
        name: event.name,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      if (response.success && response.data != null) {
        emit(AuthAuthenticated(response.data!));
      } else {
        emit(AuthError(response.error ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _apiClient.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthUnauthenticated()); // Always logout on error
    }
  }
}
