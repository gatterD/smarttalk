part of 'UsersMessageBloc.dart';

abstract class UsersMessageEvent {}

class LoadInitialData extends UsersMessageEvent {
  final bool isMultiConversation;
  final int convID;
  final String secondUserName;

  LoadInitialData(
      {required this.isMultiConversation,
      required this.convID,
      required this.secondUserName});
}

class SendMessage extends UsersMessageEvent {
  final String message;
  final bool isMultiConversation;

  SendMessage({required this.message, required this.isMultiConversation});
}

class LoadMoreMessages extends UsersMessageEvent {}
