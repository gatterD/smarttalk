import 'package:bloc/bloc.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';

part 'AutorisationEvent.dart';
part 'AutorisationState.dart';

class AutorisationBloc extends Bloc<AutorisationEvent, AutorisationState> {
  final AuthService _authService = AuthService();

  AutorisationBloc() : super(AutorisationInitial()) {
    // Регистрируем обработчик для LoginEvent
    on<LoginEvent>((event, emit) async {
      emit(AutorisationLoading()); // Состояние загрузки
      try {
        final success =
            await _authService.login(event.username, event.password);
        if (success) {
          emit(AutorisationSuccess(success.toString())); // Успешная авторизация
        } else {
          emit(AutorisationFailure('Login failed')); // Ошибка авторизации
        }
      } catch (e) {
        emit(AutorisationFailure(e.toString())); // Ошибка
      }
    });
  }
}
