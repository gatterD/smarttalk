import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/repository/UsersMessageRepository.dart';

part 'UsersMessageEvent.dart';
part 'UsersMessageState.dart';

class UsersMessageBloc extends Bloc<UsersMessageEvent, UsersMessageState> {
  final UsersMessageRepository _repository;
  late int _currentUserId;
  late String _currentUsername;
  late int _conversationId;
  late int _secondUserID;
  List<dynamic> _blackList = [];
  bool _isBlocked = false;

  UsersMessageBloc(this._repository) : super(UsersMessageInitial()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event, Emitter<UsersMessageState> emit) async {
    emit(UsersMessageLoading());

    try {
      _currentUserId = await _repository.loadCurrentUser();
      final prefs = await SharedPreferences.getInstance();
      _currentUsername = prefs.getString('username') ?? '';

      if (!event.isMultiConversation) {
        // Для личных сообщений
        _secondUserID =
            await _repository.getUserIdByUsername(event.secondUserName);
        _conversationId = await _repository.initializeConversation(
            _currentUserId, event.convID);
        _blackList = await _repository.getBlackList(event.convID.toString());
        _isBlocked =
            await _repository.chekBlackList(_blackList, _currentUserId);

        final messages = await _repository.loadMessages(_conversationId);

        emit(UsersMessageLoaded(
            messages: messages,
            currentUserId: _currentUserId,
            conversationId: _conversationId,
            currentUsername: _currentUsername,
            blackList: _blackList,
            isBlocked: _isBlocked,
            secondUserID: _secondUserID));
      } else {
        // Для групповых чатов
        final messages = await _repository.fetchMultiConvMessages(event.convID);

        emit(UsersMessageLoaded(
          messages: messages,
          currentUserId: _currentUserId,
          conversationId: event.convID,
          currentUsername: _currentUsername,
          blackList: [],
          isBlocked: false,
          secondUserID: event.convID,
        ));
      }
    } catch (e) {
      emit(UsersMessageError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<UsersMessageState> emit) async {
    if (state is! UsersMessageLoaded) return;

    final currentState = state as UsersMessageLoaded;

    try {
      if (!event.isMultiConversation) {
        await _repository.sendMessage(
          event.message,
          currentState.conversationId,
          currentState.currentUserId,
          currentState.secondUserID,
        );
      } else {
        await _repository.sendNewMultiMessage(
          event.message,
          currentState.conversationId,
          currentState.currentUserId,
          currentState.currentUsername,
        );
      }

      final messages = event.isMultiConversation
          ? await _repository
              .fetchMultiConvMessages(currentState.conversationId)
          : await _repository.loadMessages(currentState.conversationId);

      emit(MessageSent(messages: messages));
      emit(currentState.copyWith(messages: messages));
    } catch (e) {
      emit(UsersMessageError(message: e.toString()));
    }
  }
}
