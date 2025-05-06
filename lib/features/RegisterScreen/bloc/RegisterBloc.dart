import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/models/User.dart';
import 'package:smarttalk/repository/RegisterRepository.dart';

part 'RegisterEvent.dart';
part 'RegisterState.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;
  final AuthService authService;
  User? _currentUser;

  RegisterBloc({
    required this.authService,
    required this.repository,
  }) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterFavoriteChatCreation>(_onRegisterSuccses);
  }

  User? get currentUser => _currentUser;

  Future<void> _onRegisterSuccses(
    RegisterFavoriteChatCreation event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      if (_currentUser == null || _currentUser!.username.isEmpty) {
        throw Exception('User data is not available');
      }

      int userID = await repository.getUserIdByUsername(_currentUser!.username);
      await repository.CreateConversation(userID.toString(), userID.toString());
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(
          error:
              'An error occurred during favorite chat creation: ${e.toString()}'));
    }
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
      final success = await authService.register(user);
      if (success) {
        _currentUser = user;
        emit(RegisterCreatingFavoritesSuccess());
      } else {
        emit(RegisterFailure(error: 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure(
          error: 'An error occurred during registration: ${e.toString()}'));
    }
  }
}
