import 'package:bloc/bloc.dart';
import 'package:smarttalk/repository/BlackListRepository.dart';

part 'BlackListEvent.dart';
part 'BlackListState.dart';

class BlackListBloc extends Bloc<BlackListEvent, BlackListState> {
  final BlackListRepository _blackListRep;
  String? userID;

  BlackListBloc(this._blackListRep) : super(BlackListInitialState()) {
    on<LoadBLCurrentUserID>((event, emit) async {
      emit(BlackListLoadingUserState());
      try {
        userID = (await _blackListRep.getCurrentUserId())!;

        emit(BlackListLoadedUserState(userID!));
      } catch (e) {
        emit(BlackListErrorState(e.toString()));
      }
    });

    on<LoadBlackListEvent>((event, emit) async {
      if (userID == null) {
        emit(BlackListErrorState("User ID not loaded"));
        return;
      }

      emit(BlackListLoadingState());

      try {
        List<dynamic> users = await _blackListRep.fetchBlackList(userID!);

        emit(BlackListLoadedState(users));
      } catch (e) {
        emit(BlackListErrorState(e.toString()));
      }
    });

    on<RemoveFromBlackListEvent>((event, emit) async {
      if (userID == null) {
        emit(BlackListErrorState("User ID not loaded"));
        return;
      }

      emit(BlackListLoadingState());

      try {
        await _blackListRep.deleteFromBlackList(
            userBLID: event.blockedUserId, currentUserID: userID!);

        List<dynamic> users = await _blackListRep.fetchBlackList(userID!);

        emit(BlackListLoadedState(users));
      } catch (e) {
        emit(BlackListErrorState(e.toString()));
      }
    });
  }
}
