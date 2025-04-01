import 'package:flutter/material.dart';
import 'package:smarttalk/theme/theme.dart';

class ChatCreation extends StatefulWidget {
  const ChatCreation({super.key});

  @override
  State<ChatCreation> createState() => _ChatCreationState();
}

class _ChatCreationState extends State<ChatCreation> {
  final TextEditingController _chatNameController = TextEditingController();
  final List<String> _addedUsers = []; // Список добавленных пользователей
  final List<String> _availableUsers = [
    // Список доступных для добавления пользователей
    'User1', 'User2', 'User3', 'User4', 'User5'
  ];

  @override
  void dispose() {
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание чата'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Зона названия чата
            TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(
                hintText: 'Название чата',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Добавленные участники:',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              height: 100,
              child: _addedUsers.isEmpty
                  ? Center(
                      child: Text(
                      'Пока никого нет',
                      style: theme.textTheme.labelSmall,
                    ))
                  : ListView.builder(
                      itemCount: _addedUsers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _addedUsers[index],
                            style: theme.textTheme.labelMedium,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _availableUsers.add(_addedUsers[index]);
                                _addedUsers.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // Зона доступных пользователей
            Text(
              'Доступные пользователи:',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _availableUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _availableUsers[index],
                        style: theme.textTheme.labelMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _addedUsers.add(_availableUsers[index]);
                            _availableUsers.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Кнопка создания чата
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_chatNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Введите название чата')),
                    );
                    return;
                  }

                  if (_addedUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Добавьте хотя бы одного участника')),
                    );
                    return;
                  }

                  // Здесь логика создания чата
                  print('Создан чат: ${_chatNameController.text}');
                  print('Участники: $_addedUsers');

                  Navigator.pop(context);
                },
                child: const Text('Создать чат'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
