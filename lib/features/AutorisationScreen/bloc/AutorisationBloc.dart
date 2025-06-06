import 'package:bloc/bloc.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';

part 'AutorisationEvent.dart';
part 'AutorisationState.dart';

class AutorisationBloc extends Bloc<AutorisationEvent, AutorisationState> {
  final AuthService _authService = AuthService();

  AutorisationBloc() : super(AutorisationInitial()) {
    on<AutoLoginRequested>(_onAutoLogin);
    on<LoginEvent>((event, emit) async {
      emit(AutorisationLoading());
      try {
        final success =
            await _authService.login(event.username, event.password);
        if (success) {
          emit(AutorisationSuccess(success.toString()));
        } else {
          emit(AutorisationFailure('Login failed'));
        }
      } catch (e) {
        emit(AutorisationFailure(e.toString()));
      }
    });
  }
  Future<void> _onAutoLogin(
    AutoLoginRequested event,
    Emitter<AutorisationState> emit,
  ) async {
    emit(AutorisationLoading());

    try {
      final success = await _authService.autoLoginByIp();
      if (success) {
        emit(AutorisationSuccess(success.toString()));
      } else {
        emit(AutorisationFailure('Login failed'));
      }
    } catch (e) {
      emit(AutorisationFailure(e.toString()));
    }
  }
}
