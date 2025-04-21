part of 'ChatCreationBloc.dart';

abstract class ChatCreationState {
  const ChatCreationState();
}

class ChatCreationInitial extends ChatCreationState {}

class ChatCreationLoading extends ChatCreationState {}

class ChatCreationLoaded extends ChatCreationState {
  final String? currentUserId;
  final List<dynamic> availableUsers;
  final List<dynamic> addedUsers;

  const ChatCreationLoaded({
    required this.currentUserId,
    required this.availableUsers,
    required this.addedUsers,
  });
}

class ChatCreationError extends ChatCreationState {
  final String message;

  const ChatCreationError(this.message);
}

class ChatCreatedSuccess extends ChatCreationState {}
