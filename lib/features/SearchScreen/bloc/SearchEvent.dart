part of 'SearchBloc.dart';

abstract class SearchEvent {}

class LoadingUserIDSearchEvent extends SearchEvent {}

class LoadingBlackListSearchEvent extends SearchEvent {}

class LoadingFriendsSearchEvent extends SearchEvent {}

class LoadingUsersSearchEvent extends SearchEvent {
  final String query;

  LoadingUsersSearchEvent(this.query);
}

class AddToFriendSearchEvent extends SearchEvent {}

class OpenDialogSearchEvent extends SearchEvent {}
