part of 'UsersMessageBloc.dart';

abstract class UsersMessageState {}

class UsersMessageInitial extends UsersMessageState {}

class UsersMessageLoading extends UsersMessageState {}

class UsersMessageLoaded extends UsersMessageState {
  final List<dynamic> messages;
  final int currentUserId;
  final int conversationId;
  final String currentUsername;
  final List<dynamic> blackList;
  final bool isBlocked;

  UsersMessageLoaded({
    required this.messages,
    required this.currentUserId,
    required this.conversationId,
    required this.currentUsername,
    required this.blackList,
    required this.isBlocked,
  });

  UsersMessageLoaded copyWith({
    List<dynamic>? messages,
    int? currentUserId,
    int? conversationId,
    String? currentUsername,
    List<dynamic>? blackList,
    bool? isBlocked,
  }) {
    return UsersMessageLoaded(
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      conversationId: conversationId ?? this.conversationId,
      currentUsername: currentUsername ?? this.currentUsername,
      blackList: blackList ?? this.blackList,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

class UsersMessageError extends UsersMessageState {
  final String message;

  UsersMessageError({required this.message});
}

class MessageSent extends UsersMessageState {
  final List<dynamic> messages;

  MessageSent({required this.messages});
}
