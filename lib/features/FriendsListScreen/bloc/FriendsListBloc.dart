import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarttalk/repository/FriendsListRepository.dart';
import 'package:smarttalk/models/UsersPhotoModel.dart';

part 'FriendsListEvent.dart';
part 'FriendsListState.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendsRepository repository;
  final UsersPhotoModel _photoModel = UsersPhotoModel();

  List<dynamic> friends = [];
  List<dynamic> pinnedFriends = [];
  List<dynamic> pinnedFriendsList = [];
  List<dynamic> sortedFriends = [];
  List<dynamic> otherConversations = [];
  List<dynamic> otherConversationsIDs = [];
  List<dynamic> multiConversations = [];
  String? currentUserId;
  String? currentUsername;

  FriendsBloc(this.repository) : super(FriendsLoadingState()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<PinConversationEvent>(_onPinConversation);
    on<UnpinConversationEvent>(_onUnpinUser);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadFriends(
      LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    try {
      currentUserId = await repository.getCurrentUserId();
      currentUsername = await repository.getCurrentUsername();

      if (currentUserId == null) {
        emit(FriendsErrorState('User not authenticated'));
        return;
      }

      friends = await repository.fetchFriends(currentUserId!);
      pinnedFriends = await repository.fetchPinnedFriends(currentUserId!);

      // Process other conversations
      final otherConvs =
          await repository.fetchOtherConversations(currentUserId!);
      otherConversationsIDs = otherConvs.map((conv) {
        return conv['user1_id'].toString() == currentUserId
            ? conv['user2_id'].toString()
            : conv['user1_id'].toString();
      }).toList();

      // Get user info for other conversations
      otherConversations = [];
      for (var id in otherConversationsIDs) {
        if (!friends.any((friend) => friend['id'].toString() == id)) {
          final userInfo = await repository.getUserInfo(id);
          otherConversations.add(userInfo);
        }
      }

      // Process multi conversations
      multiConversations =
          await repository.fetchMultiConversations(currentUserId!);
      multiConversations = multiConversations.map((conversation) {
        return {
          'id': int.parse(conversation['id']),
          'username': conversation['conversation_name'],
        };
      }).toList();

      final pinnedConversationsList = pinnedFriends
          .map((id) {
            final friend = friends.firstWhere((friend) => friend["id"] == id,
                orElse: () => <String, dynamic>{});
            if (friend.isNotEmpty) return friend;

            final otherConv = otherConversations.firstWhere(
                (conv) => conv["id"] == id,
                orElse: () => <String, dynamic>{});
            if (otherConv.isNotEmpty) return otherConv;

            final multiConv = multiConversations.firstWhere(
                (conv) => conv["id"] == id,
                orElse: () => <String, dynamic>{});
            if (multiConv.isNotEmpty) return multiConv;

            return null;
          })
          .where((conversation) => conversation != null)
          .toList();
      sortedFriends = [
        ...pinnedConversationsList,
        ...friends.where((friend) => !pinnedFriends.contains(friend["id"])),
        ...otherConversations
            .where((conv) => !pinnedFriends.contains(conv["id"])),
        ...multiConversations
            .where((conv) => !pinnedFriends.contains(conv["id"])),
      ];

      final BlacListUsers = await repository.getBlacklist(currentUserId!);
      sortedFriends =
          await repository.deleteBLUsers(sortedFriends, BlacListUsers);

      String? token_IP = await repository.getCurrentUserToken();
      sortedFriends = await _photoModel.enrichUsersWithPhotos(sortedFriends);
      emit(FriendsLoadedState(
        sortedFriends: sortedFriends,
        pinnedFriends: pinnedFriends,
        otherConversations: otherConversations,
        multiConversations: multiConversations,
        currentUserId: currentUserId!,
        currentUsername: currentUsername ?? '',
        token_IP: token_IP ?? '',
        Admin_IP: repository.adminIP,
      ));
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  Future<void> _onPinConversation(
      PinConversationEvent event, Emitter<FriendsState> emit) async {
    try {
      if (currentUserId == null) return;
      if (pinnedFriends.length >= 5) {
        emit(FriendsErrorState('You cannot pin more than 5 friends.'));
        return;
      }
      await repository.pinConversation(currentUserId!, event.friendId);
      add(LoadFriendsEvent());
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  Future<void> _onUnpinUser(
      UnpinConversationEvent event, Emitter<FriendsState> emit) async {
    try {
      if (currentUserId == null) return;

      await repository.unpinUser(currentUserId!, event.friendId);
      add(LoadFriendsEvent());
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteConversation(
      DeleteConversationEvent event, Emitter<FriendsState> emit) async {
    try {
      if (currentUserId == null) return;

      await repository.deleteConversation(currentUserId!, event.friendId);
      add(LoadFriendsEvent());
    } catch (e) {
      emit(FriendsErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<FriendsState> emit) async {
    await repository.logout();
  }
}
