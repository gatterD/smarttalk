part of 'ChatCreationBloc.dart';

abstract class ChatCreationEvent {}

class LoadCurrentUserEvent extends ChatCreationEvent {}

class FetchFriendsEvent extends ChatCreationEvent {
  final String userId;

  FetchFriendsEvent(this.userId);
}

class AddUserEvent extends ChatCreationEvent {
  final dynamic user;

  AddUserEvent(this.user);
}

class RemoveUserEvent extends ChatCreationEvent {
  final dynamic user;
  final int index;

  RemoveUserEvent(this.user, this.index);
}

class CreateChatEvent extends ChatCreationEvent {
  final String chatName;
  final BuildContext context;

  CreateChatEvent(this.chatName, this.context);
}
