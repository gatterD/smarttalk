part of 'UserSettingsBloc.dart';

abstract class UserSettingsState {}

class UserProfileInitial extends UserSettingsState {}

class UserProfileLoading extends UserSettingsState {}

class PhotoUploadSuccess extends UserSettingsState {}

class PhotoLoaded extends UserSettingsState {
  final Uint8List? photoData;

  PhotoLoaded(this.photoData);
}

class UserProfileError extends UserSettingsState {
  final String message;

  UserProfileError(this.message);
}
