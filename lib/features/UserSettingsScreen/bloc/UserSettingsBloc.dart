import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:smarttalk/repository/UserSettingsRepository.dart';

part 'UserSettingsEvent.dart';
part 'UserSettingsState.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  final UserSettingsRepository repository;

  UserSettingsBloc({required this.repository}) : super(UserProfileInitial()) {
    on<UploadPhotoEvent>(_onUploadPhoto);
    on<LoadPhotoEvent>(_onLoadPhoto);
  }

  Future<void> _onUploadPhoto(
    UploadPhotoEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      await repository.uploadPhoto(event.userId, event.imageFile);
      emit(PhotoUploadSuccess());
      add(LoadPhotoEvent(event.userId));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLoadPhoto(
    LoadPhotoEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final photoData = await repository.getLatestPhoto(event.userId);
      emit(PhotoLoaded(photoData));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
