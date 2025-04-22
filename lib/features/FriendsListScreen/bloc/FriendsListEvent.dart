part of 'FriendsListBloc.dart';

abstract class FriendsEvent {}

class LoadFriendsEvent extends FriendsEvent {}

class PinConversationEvent extends FriendsEvent {
  final String friendId;
  PinConversationEvent(this.friendId);
}

class DeleteConversationEvent extends FriendsEvent {
  final String friendId;
  DeleteConversationEvent(this.friendId);
}

class LogoutEvent extends FriendsEvent {}
