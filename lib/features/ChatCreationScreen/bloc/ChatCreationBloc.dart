import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarttalk/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/repository/ChatCreationRepository.dart';

part 'ChatCreationEvent.dart';
part 'ChatCreationState.dart';

class ChatCreationBloc extends Bloc<ChatCreationEvent, ChatCreationState> {
  final ChatCreationRepository repository;
  final String baseUrl = dotenv.get('BASEURL');

  ChatCreationBloc({required this.repository}) : super(ChatCreationInitial()) {
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<FetchFriendsEvent>(_onFetchFriends);
    on<AddUserEvent>(_onAddUser);
    on<RemoveUserEvent>(_onRemoveUser);
    on<CreateChatEvent>(_onCreateChat);
  }

  Future<void> _onLoadCurrentUser(
      LoadCurrentUserEvent event, Emitter<ChatCreationState> emit) async {
    emit(ChatCreationLoading());
    try {
      final userId = await repository.loadCurrentUserId();
      if (userId != null) {
        add(FetchFriendsEvent(userId));
        emit(ChatCreationLoaded(
          currentUserId: userId,
          availableUsers: [],
          addedUsers: [],
        ));
      } else {
        emit(const ChatCreationError('User ID not found'));
      }
    } catch (e) {
      emit(ChatCreationError(e.toString()));
    }
  }

  Future<void> _onFetchFriends(
      FetchFriendsEvent event, Emitter<ChatCreationState> emit) async {
    if (state is ChatCreationLoaded) {
      final currentState = state as ChatCreationLoaded;
      try {
        final friends = await repository.fetchFriends(event.userId);
        emit(ChatCreationLoaded(
          currentUserId: currentState.currentUserId,
          availableUsers: friends,
          addedUsers: currentState.addedUsers,
        ));
      } catch (e) {
        emit(ChatCreationError(e.toString()));
      }
    }
  }

  void _onAddUser(AddUserEvent event, Emitter<ChatCreationState> emit) {
    if (state is ChatCreationLoaded) {
      final currentState = state as ChatCreationLoaded;
      final updatedAvailableUsers = List.from(currentState.availableUsers)
        ..remove(event.user);
      final updatedAddedUsers = List.from(currentState.addedUsers)
        ..add(event.user);

      emit(ChatCreationLoaded(
        currentUserId: currentState.currentUserId,
        availableUsers: updatedAvailableUsers,
        addedUsers: updatedAddedUsers,
      ));
    }
  }

  void _onRemoveUser(RemoveUserEvent event, Emitter<ChatCreationState> emit) {
    if (state is ChatCreationLoaded) {
      final currentState = state as ChatCreationLoaded;
      final updatedAddedUsers = List.from(currentState.addedUsers)
        ..removeAt(event.index);
      final updatedAvailableUsers = List.from(currentState.availableUsers)
        ..add(event.user);

      emit(ChatCreationLoaded(
        currentUserId: currentState.currentUserId,
        availableUsers: updatedAvailableUsers,
        addedUsers: updatedAddedUsers,
      ));
    }
  }

  Future<void> _onCreateChat(
      CreateChatEvent event, Emitter<ChatCreationState> emit) async {
    if (state is ChatCreationLoaded) {
      final currentState = state as ChatCreationLoaded;
      try {
        await repository.chatCreate(
          TextEditingController(text: event.chatName),
          currentState.currentUserId!,
          currentState.addedUsers,
          event.context,
        );
        emit(ChatCreatedSuccess());
      } catch (e) {
        emit(ChatCreationError(e.toString()));
      }
    }
  }
}
