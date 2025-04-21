import 'package:flutter/material.dart';
import 'package:smarttalk/repository/UsersMessageRepository.dart';
import 'package:smarttalk/theme/theme.dart';
import 'package:smarttalk/features/UsersMessageScreen/bloc/UsersMessageBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersMessageScreen extends StatelessWidget {
  final String usersName;
  final bool isMultiConversation;
  final int convID;

  const UsersMessageScreen({
    super.key,
    required this.usersName,
    required this.isMultiConversation,
    required this.convID,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersMessageBloc(UsersMessageRepository())
        ..add(LoadInitialData(
          isMultiConversation: isMultiConversation,
          convID: convID,
        )),
      child: _UsersMessageView(
        usersName: usersName,
        isMultiConversation: isMultiConversation,
        convID: convID,
      ),
    );
  }
}

class _UsersMessageView extends StatelessWidget {
  final String usersName;
  final bool isMultiConversation;
  final int convID;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  _UsersMessageView({
    required this.usersName,
    required this.isMultiConversation,
    required this.convID,
  });

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(usersName)),
      body: BlocConsumer<UsersMessageBloc, UsersMessageState>(
        listener: (context, state) {
          if (state is MessageSent) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is UsersMessageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersMessageError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is UsersMessageLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return Align(
                        alignment: message['sender_id'] == state.currentUserId
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              message['sender_id'] == state.currentUserId
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                message['sender_id'] == state.currentUserId
                                    ? state.currentUsername
                                    : isMultiConversation
                                        ? message['sender_name']
                                        : usersName,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    message['sender_id'] == state.currentUserId
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(message['content']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: state.isBlocked
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Данный пользователь добавил вас в Черный список',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Напишите сообщение...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  context.read<UsersMessageBloc>().add(
                                        SendMessage(
                                          messageController: _messageController,
                                          message: _messageController.text,
                                          isMultiConversation:
                                              isMultiConversation,
                                        ),
                                      );
                                  _messageController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          }
          return const SizedBox(); // Fallback
        },
      ),
    );
  }
}
