import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthInitialEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
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
  final String userId;

  const AuthAuthenticated(this.userId);

  @override
  List<Object> get props => [userId];
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
  AuthBloc({
    required dynamic loginUseCase,
    required dynamic registerUseCase,
    required dynamic logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthInitialEvent>(_onInitial);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  void _onInitial(AuthInitialEvent event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }

  void _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 1));
      emit(const AuthAuthenticated('user_123'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
