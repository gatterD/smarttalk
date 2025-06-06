import 'package:smarttalk/repository/SearchRepository.dart';
import 'package:bloc/bloc.dart';

part 'SearchEvent.dart';
part 'SearchState.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchRepository _searchRepository;
  String? userID;
  List<dynamic>? black_list = [];
  List<dynamic>? friends = [];

  SearchBloc(this._searchRepository) : super(InitialSearchState()) {
    on<LoadingUserIDSearchEvent>((event, emit) async {
      emit(LoadingSearchState());
      try {
        userID = await _searchRepository.loadCurrentUserId();

        emit(LoadedUserIDSearchState());
      } catch (e) {
        emit(ErrorSearchState(e.toString()));
      }
    });

    on<LoadingBlackListSearchEvent>((event, emit) async {
      try {
        if (userID == null) {
          throw "Have no user ID";
        }
        black_list = await _searchRepository.fetchBLUsers(userID!);
      } catch (e) {
        emit(ErrorSearchState(e.toString()));
      }
    });

    on<LoadingFriendsSearchEvent>((event, emit) async {
      emit(LoadingSearchState());
      try {
        if (userID == null) {
          throw "Have no user ID";
        }
        friends = await _searchRepository.fetchFriends(userID!);
        emit(LoadedInitialSearchState());
      } catch (e) {
        emit(ErrorSearchState(e.toString()));
      }
    });

    on<LoadingUsersSearchEvent>((event, emit) async {
      try {
        if (userID == null) {
          throw "Have no user ID";
        }
        List<dynamic>? users;
        users = await _searchRepository.searchUsers(event.query, black_list!);
        emit(LoadedSearchState(users, friends!, int.parse(userID!)));
      } catch (e) {
        emit(ErrorSearchState(e.toString()));
      }
    });

    on<AddToFriendSearchEvent>((event, emit) async {
      try {
        if (userID == null) {
          throw "Have no user ID";
        }
        _searchRepository.addFriend(event.friendId, int.parse(userID!));
        emit(SuccsesfulAddFriendSearchState());
      } catch (e) {
        emit(ErrorSearchState(e.toString()));
      }
    });
  }
}
