part of 'BlackListBloc.dart';

abstract class BlackListEvent {}

class LoadBLCurrentUserID extends BlackListEvent {}

class LoadBlackListEvent extends BlackListEvent {}

class LoadBlackListUser extends BlackListEvent {}

class RemoveFromBlackListEvent extends BlackListEvent {
  final String currentUserId;
  final int blockedUserId;

  RemoveFromBlackListEvent({
    required this.currentUserId,
    required this.blockedUserId,
  });
}
