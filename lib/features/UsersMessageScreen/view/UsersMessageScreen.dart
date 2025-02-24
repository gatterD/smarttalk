import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UsersMessageScreen extends StatefulWidget {
  final String usersName;
  const UsersMessageScreen({super.key, required this.usersName});

  @override
  _UsersMessageScreenState createState() => _UsersMessageScreenState();
}

class _UsersMessageScreenState extends State<UsersMessageScreen> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  late int currentUserId;
  late int conversationId;
  late int secondUserID;
  late String currentUsername;

  @override
  void initState() {
    super.initState(); // Всегда вызывайте super.initState() первым
    _initializeData();
  }

  void _initializeData() async {
    await _loadCurrentUser();
    await _loadSecondUserId();
    await _initializeConversation();
    _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username') ?? '';
    if (currentUsername.isNotEmpty) {
      currentUserId = await _getUserIdByUsername(currentUsername);
    }
  }

  Future<void> _loadSecondUserId() async {
    secondUserID = await _getUserIdByUsername(widget.usersName);
  }

  Future<int> _getUserIdByUsername(String name) async {
    final baseUrl = dotenv.get('BASEURL');
    final response = await http.get(
      Uri.parse('$baseUrl/users/id?username=$name'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Ошибка загрузки ID пользователя');
    }
  }

  Future<void> _initializeConversation() async {
    final convId = await getOrCreateConversation(
      currentUserId.toString(),
      secondUserID.toString(),
    );
    setState(() {
      conversationId = convId;
    });
  }

  Future<int> getOrCreateConversation(String user1Id, String user2Id) async {
    final baseUrl = dotenv.get('BASEURL');
    final response = await http.get(
      Uri.parse(
          '$baseUrl/conversations/id?user1_id=$user1Id&user2_id=$user2Id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['conversation_id'];
    } else if (response.statusCode == 404) {
      final createResponse = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'user1_id': user1Id, 'user2_id': user2Id}),
      );
      if (createResponse.statusCode == 201) {
        return jsonDecode(createResponse.body)['id'];
      }
    }
    throw Exception('Ошибка создания/получения беседы');
  }

  Future<void> _loadMessages() async {
    final response = await http
        .get(Uri.parse('${dotenv.get('BASEURL')}/messages/$conversationId'));
    debugPrint(response.statusCode.toString());
    if (response.statusCode == 200) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Добавляем сообщение в локальный список

    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': secondUserID,
        'content': messageText,
      }),
    );

    if (response.statusCode == 201) {
      // Обновляем сообщения после успешной отправки
      _loadMessages();
    } else {
      // Если отправка не удалась, удаляем сообщение из локального списка
      setState(() {
        messages.removeLast();
      });
      debugPrint('Ошибка отправки сообщения');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.usersName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender_id'] == currentUserId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message['sender_id'] == currentUserId
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['content']),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
            child: Row(
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
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
