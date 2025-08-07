import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

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
  final ApiService _apiService;

  SubscriptionBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(SubscriptionInitial()) {
    on<LoadSubscriptionEvent>(_onLoadSubscription);
    on<UpgradeSubscriptionEvent>(_onUpgradeSubscription);
  }

  Future<void> _onLoadSubscription(
      LoadSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final subscription = await _apiService.getSubscription();
      emit(SubscriptionLoaded(subscription));
    } on ApiError catch (e) {
      emit(SubscriptionError(e.message ?? 'Failed to load subscription'));
    } catch (e) {
      emit(SubscriptionError('An unexpected error occurred'));
    }
  }

  Future<void> _onUpgradeSubscription(
      UpgradeSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final result = await _apiService.upgradeSubscription(event.planType);
      emit(SubscriptionLoaded(result));
    } on ApiError catch (e) {
      emit(SubscriptionError(e.message ?? 'Failed to upgrade subscription'));
    } catch (e) {
      emit(SubscriptionError('An unexpected error occurred'));
    }
  }
}
