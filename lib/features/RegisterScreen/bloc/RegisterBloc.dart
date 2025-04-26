import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/models/User.dart';

part 'RegisterEvent.dart';
part 'RegisterState.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;

  RegisterBloc({required AuthService authService})
      : _authService = authService,
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      final user = User(
        username: event.username,
        password: event.password,
      );
      final success = await _authService.register(user);
      if (success) {
        emit(RegisterSuccess());
      } else {
        emit(RegisterFailure(error: 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure(error: 'An error occurred during registration'));
    }
  }
}
