part of 'UserSettingsBloc.dart';

abstract class UserSettingsEvent {}

class UploadPhotoEvent extends UserSettingsEvent {
  final int userId;
  final File imageFile;

  UploadPhotoEvent({required this.userId, required this.imageFile});
}

class LoadPhotoEvent extends UserSettingsEvent {
  final int userId;

  LoadPhotoEvent(this.userId);
}
