import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:smarttalk/features/ChatCreationScreen/bloc/ChatCreationBloc.dart';
import 'package:smarttalk/repository/ChatCreationRepository.dart';
import 'package:smarttalk/provider/ThemeProvider.dart'; // Import ThemeProvider

class ChatCreationScreen extends StatelessWidget {
  ChatCreationScreen({super.key});

  final TextEditingController _chatNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCreationBloc(
        repository: ChatCreationRepository(),
      )..add(LoadCurrentUserEvent()),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Создание чата',
                style: themeProvider.currentTheme.textTheme.headlineLarge,
              ),
            ),
            body: BlocConsumer<ChatCreationBloc, ChatCreationState>(
              listener: (context, state) {
                if (state is ChatCreationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is ChatCreatedSuccess) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/friend_list");
                }
              },
              builder: (context, state) {
                if (state is ChatCreationLoading ||
                    state is ChatCreationInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatCreationError) {
                  return Center(child: Text(state.message));
                } else if (state is ChatCreationLoaded) {
                  return _buildLoadedState(context, state, themeProvider);
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, ChatCreationLoaded state,
      ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _chatNameController,
            decoration: InputDecoration(
              hintText: 'Название чата',
              hintStyle: themeProvider.currentTheme.textTheme.bodyMedium,
            ),
            style: themeProvider.currentTheme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('Добавленные участники:',
              style: themeProvider.currentTheme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Container(
            height: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: state.addedUsers.isEmpty
                ? Center(
                    child: Text(
                      'Пока никого нет',
                      style: themeProvider.currentTheme.textTheme.labelSmall,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.addedUsers.map((user) {
                      final index = state.addedUsers.indexOf(user);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 100, 148, 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user['username'],
                              style: themeProvider
                                  .currentTheme.textTheme.labelMedium,
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<ChatCreationBloc>()
                                    .add(RemoveUserEvent(user, index));
                              },
                              child: const Icon(Icons.close,
                                  color: Colors.red, size: 18),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),
          Text('Доступные пользователи:',
              style: themeProvider.currentTheme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: state.availableUsers.length,
                itemBuilder: (context, index) {
                  final user = state.availableUsers[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromRGBO(19, 41, 61, 0.9),
                    child: ListTile(
                      title: Text(
                        user['username'],
                        style: themeProvider.currentTheme.textTheme.labelMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.green),
                        onPressed: () {
                          context
                              .read<ChatCreationBloc>()
                              .add(AddUserEvent(user));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 100, 148, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_chatNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите название чата')),
                  );
                  return;
                }

                if (state.addedUsers.isEmpty || state.addedUsers.length == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Добавьте хотя бы двух участников')),
                  );
                  return;
                }

                context.read<ChatCreationBloc>().add(
                      CreateChatEvent(
                        _chatNameController.text,
                        context,
                      ),
                    );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Создать чат'),
            ),
          ),
        ],
      ),
    );
  }
}
