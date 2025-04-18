import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smarttalk/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatCreation extends StatefulWidget {
  const ChatCreation({super.key});

  @override
  State<ChatCreation> createState() => _ChatCreationState();
}

class _ChatCreationState extends State<ChatCreation> {
  TextEditingController _chatNameController = TextEditingController();
  List<dynamic> _addedUsers = [];
  List<dynamic> _availableUsers = [];
  final String baseUrl = dotenv.get('BASEURL');
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  @override
  void dispose() {
    _chatNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('id');

    if (userID != null) {
      setState(() {
        _currentUserId = userID;
      });
      await _fetchFriends(userID);
    }
  }

  Future<void> _fetchFriends(String userID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userID/friends'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _availableUsers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки списка друзей: $e");
    }
  }

  Future<void> chatCreate() async {
    try {
      final chatName = _chatNameController.text;
      final chatIDS = [int.parse(_currentUserId!)];
      for (var item in _addedUsers) {
        chatIDS.add(item['id']);
      }
      final response = await http.post(
        Uri.parse('$baseUrl/multi/conversation/add'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"convname": chatName, "users": chatIDS}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Беседа успешно создана')),
        );
      }
    } catch (e) {
      debugPrint("Ошибка ошибка добавления беседы: $e");
    }
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
                            _addedUsers[index]['username'],
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
                        _availableUsers[index]['username'],
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

                  if (_addedUsers.isEmpty || _addedUsers.length == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Добавьте хотя бы двух участников')),
                    );
                    return;
                  }

                  chatCreate();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/friend_list");
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
