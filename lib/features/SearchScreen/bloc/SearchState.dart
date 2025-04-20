part of 'SearchBloc.dart';

abstract class SearchState {}

class InitialSearchState extends SearchState {}

class LoadingSearchState extends SearchState {}

class LoadedSearchState extends SearchState {
  final List<dynamic> users;
  final List<dynamic> friends;

  LoadedSearchState(this.users, this.friends);
}

class ErrorSearchState extends SearchState {
  final String error;

  ErrorSearchState(this.error);
}
