part of 'FriendsListBloc.dart';

abstract class FriendsState {}

class FriendsLoadingState extends FriendsState {}

class FriendsLoadedState extends FriendsState {
  final List<dynamic> sortedFriends;
  final List<dynamic> pinnedFriends;
  final List<dynamic> otherConversations;
  final List<dynamic> multiConversations;
  final String currentUserId;
  final String currentUsername;

  FriendsLoadedState({
    required this.sortedFriends,
    required this.pinnedFriends,
    required this.otherConversations,
    required this.multiConversations,
    required this.currentUserId,
    required this.currentUsername,
  });
}

class FriendsErrorState extends FriendsState {
  final String error;
  FriendsErrorState(this.error);
}
