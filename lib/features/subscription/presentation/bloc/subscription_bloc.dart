import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionEvent extends SubscriptionEvent {}

class UpgradeSubscriptionEvent extends SubscriptionEvent {}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final String subscriptionType;
  final int coursesLimit;

  const SubscriptionLoaded(this.subscriptionType, this.coursesLimit);

  @override
  List<Object> get props => [subscriptionType, coursesLimit];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    required dynamic getSubscriptionStatusUseCase,
    required dynamic upgradeSubscriptionUseCase,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionEvent>(_onLoadSubscription);
    on<UpgradeSubscriptionEvent>(_onUpgradeSubscription);
  }

  void _onLoadSubscription(
      LoadSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      // TODO: Implement subscription loading logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const SubscriptionLoaded('free', 2));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  void _onUpgradeSubscription(
      UpgradeSubscriptionEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      // TODO: Implement subscription upgrade logic
      await Future.delayed(const Duration(seconds: 2));
      emit(const SubscriptionLoaded('pro', -1));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
