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
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  void _initializeConversation() async {
    try {
      secondUserID =
          _getUserIdByUsername(widget.usersName.toString(), secondUserID)
              as int;
      final convId = await getOrCreateConversation(
          currentUserId.toString(), secondUserID.toString());
      if (convId != null) {
        setState(() {
          conversationId = convId;
        });
        _loadMessages();
      }
    } catch (e) {
      debugPrint('Ошибка: $e');
    }
  }

  Future<int?> getOrCreateConversation(String user1Id, String user2Id) async {
    final baseUrl = dotenv.get('BASEURL');

    // Пытаемся найти беседу
    final response = await http.get(
      Uri.parse('$baseUrl/conversations?user1_id=$user1Id&user2_id=$user2Id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // Возвращаем ID существующей беседы
    } else if (response.statusCode == 404) {
      // Если беседа не найдена, создаем новую
      final createResponse = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user1_id': user1Id,
          'user2_id': user2Id,
        }),
      );

      if (createResponse.statusCode == 201) {
        final data = jsonDecode(createResponse.body);
        return data['id']; // Возвращаем ID новой беседы
      }
    }

    return null; // Если произошла ошибка
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? '';
    });

    if (currentUsername.isNotEmpty) {
      currentUserId =
          (await _getUserIdByUsername(currentUsername, currentUserId))!;
    }
  }

  Future<int?> _getUserIdByUsername(String name, int UsersID) async {
    final baseUrl = dotenv.get('BASEURL');
    final response = await http.get(
      Uri.parse('$baseUrl/users/id?username=$name'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        UsersID = data['id'];
      });

      _initializeConversation();
      return UsersID;
    } else {
      debugPrint("Ошибка загрузки ID пользователя");
    }
    return null;
  }

  Future<void> _loadMessages() async {
    final response = await http.get(Uri.parse(
        '${dotenv.get('BASEURL')}/messages?conversation_id=$conversationId'));
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

    if (conversationId == null) {
      getOrCreateConversation(
          currentUsername.toString(), secondUserID.toString());
    }
    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'content': messageText,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        messages.add({'text': messageText, 'isSentByMe': true});
      });
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
                  alignment: message['isSentByMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: message['isSentByMe']
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text']),
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
