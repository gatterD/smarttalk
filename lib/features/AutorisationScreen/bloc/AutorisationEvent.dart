part of 'AutorisationBloc.dart';

abstract class AutorisationEvent {}

class LoginEvent extends AutorisationEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);
}
