part of 'SearchBloc.dart';

abstract class SearchState {}

class InitialSearchState extends SearchState {}

class LoadingSearchState extends SearchState {}

class LoadedUserIDSearchState extends SearchState {}

class LoadedSearchState extends SearchState {
  final List<dynamic> users;
  final List<dynamic> friends;
  final int userID;

  LoadedSearchState(this.users, this.friends, this.userID);
}

class ErrorSearchState extends SearchState {
  final String error;

  ErrorSearchState(this.error);
}

class SuccsesfulAddFriendSearchState extends SearchState {}

class LoadedInitialSearchState extends SearchState {}
