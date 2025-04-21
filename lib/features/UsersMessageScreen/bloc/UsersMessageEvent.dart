part of 'UsersMessageBloc.dart';

abstract class UsersMessageEvent {}

class LoadInitialData extends UsersMessageEvent {
  final bool isMultiConversation;
  final int convID;

  LoadInitialData({required this.isMultiConversation, required this.convID});
}

class SendMessage extends UsersMessageEvent {
  final String message;
  final bool isMultiConversation;
  final TextEditingController messageController;

  SendMessage(
      {required this.messageController,
      required this.message,
      required this.isMultiConversation});
}

class LoadMoreMessages extends UsersMessageEvent {}
