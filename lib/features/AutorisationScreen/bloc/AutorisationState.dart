part of 'AutorisationBloc.dart';

abstract class AutorisationState {}

class AutorisationInitial extends AutorisationState {}

class AutorisationLoading extends AutorisationState {}

class AutorisationSuccess extends AutorisationState {
  final String token;

  AutorisationSuccess(this.token);
}

class AutorisationFailure extends AutorisationState {
  final String error;

  AutorisationFailure(this.error);
}
