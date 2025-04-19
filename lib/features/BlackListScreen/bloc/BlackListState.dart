part of 'BlackListBloc.dart';

abstract class BlackListState {}

class BlackListInitialState extends BlackListState {}

class BlackListLoadingUserState extends BlackListState {}

class BlackListLoadedUserState extends BlackListState {
  final String userID;

  BlackListLoadedUserState(this.userID);
}

class BlackListLoadingState extends BlackListState {}

class BlackListLoadedState extends BlackListState {
  final List<dynamic> users;

  BlackListLoadedState(this.users);
}

class BlackListErrorState extends BlackListState {
  final String error;

  BlackListErrorState(this.error);
}
