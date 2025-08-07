import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_client.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionEvent extends SubscriptionEvent {}

class UpgradeSubscriptionEvent extends SubscriptionEvent {
  final String planType;

  const UpgradeSubscriptionEvent(this.planType);

  @override
  List<Object> get props => [planType];
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final Map<String, dynamic> subscription;

  const SubscriptionLoaded(this.subscription);

  @override
  List<Object> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final ApiClient _apiClient;

  SubscriptionBloc({
    required ApiClient apiClient,
    dynamic getSubscriptionStatusUseCase,
    dynamic upgradeSubscriptionUseCase,
  })  : _apiClient = apiClient,
        super(SubscriptionInitial()) {
    on<LoadSubscriptionEvent>(_onLoadSubscription);
    on<UpgradeSubscriptionEvent>(_onUpgradeSubscription);
  }

  void _onLoadSubscription(
      LoadSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final response = await _apiClient.getSubscription();

      if (response.success && response.data != null) {
        emit(SubscriptionLoaded(response.data!));
      } else {
        emit(
            SubscriptionError(response.error ?? 'Failed to load subscription'));
      }
    } catch (e) {
      emit(SubscriptionError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onUpgradeSubscription(
      UpgradeSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      // TODO: Implement subscription upgrade logic
      await Future.delayed(const Duration(seconds: 1));
      // Reload subscription after upgrade
      add(LoadSubscriptionEvent());
    } catch (e) {
      emit(
          SubscriptionError('Failed to upgrade subscription: ${e.toString()}'));
    }
  }
}
