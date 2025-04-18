import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smarttalk/theme/theme.dart';

class UsersMessageScreen extends StatefulWidget {
  final String usersName;
  final bool isMultiConversation;
  final int convID;
  const UsersMessageScreen(
      {super.key,
      required this.usersName,
      required this.isMultiConversation,
      required this.convID});

  @override
  _UsersMessageScreenState createState() => _UsersMessageScreenState();
}

class _UsersMessageScreenState extends State<UsersMessageScreen> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  late int currentUserId;
  late int conversationId;
  late String currentUsername;
  List<dynamic> black_list = [];
  bool chekBLUser = false;
  late ScrollController _scrollController;
  final baseUrl = dotenv.get('BASEURL');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    await _loadCurrentUser();
    if (!widget.isMultiConversation) {
      await _initializeConversation();
      await _getBlackList();
      await _chekBlackList();
      _loadMessages();
    } else {
      await fetchMultiConvMessages();
    }
  }

  // Прокручиваем список вниз
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

  Future<void> _chekBlackList() async {
    for (var blacklistItem in black_list) {
      if (blacklistItem == currentUserId) {
        chekBLUser = true;
        break;
      }
    }
  }

  Future<void> _getBlackList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/black_list/$widget.convID'),
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final decodedData = jsonDecode(response.body);
          setState(() {
            black_list = decodedData is List ? decodedData : [];
          });
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
          setState(() {
            black_list = [];
          });
        }
      } else {
        setState(() {
          black_list = [];
        });
      }
    } else {
      debugPrint('Failed to load black list: ${response.statusCode}');
      setState(() {
        black_list = [];
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username') ?? '';
    if (currentUsername.isNotEmpty) {
      currentUserId = await _getUserIdByUsername(currentUsername);
    }
  }

  Future<int> _getUserIdByUsername(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/name/$name'),
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
      widget.convID.toString(),
    );
    setState(() {
      conversationId = convId;
    });
  }

  Future<int> getOrCreateConversation(String user1Id, String user2Id) async {
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
    if (response.statusCode == 200) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageText = _messageController.text.trim();
    _messageController.clear();

    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': widget.convID,
        'content': messageText,
      }),
    );

    if (response.statusCode == 201) {
      await _loadMessages();
    } else {
      debugPrint('Ошибка отправки сообщения');
    }
  }

  Future<void> fetchMultiConvMessages() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.get('BASEURL')}/multi/chat/${widget.convID}'));
      if (response.statusCode == 200) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
        _scrollToBottom();
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Не удалось получить ID: $e");
    }
  }

  Future<void> sendNewMultiMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final messageText = _messageController.text.trim();
    _messageController.clear();

    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/multi/chat/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': widget.convID,
        'sender_id': currentUserId,
        'content': messageText,
        'sender_name': currentUsername,
      }),
    );

    if (response.statusCode == 200) {
      await fetchMultiConvMessages();
    } else {
      debugPrint('Ошибка отправки сообщения');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.usersName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Привязываем контроллер
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender_id'] == currentUserId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: message['sender_id'] == currentUserId
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message['sender_id'] == currentUserId
                              ? currentUsername
                              : widget.isMultiConversation
                                  ? message['sender_name']
                                  : widget.usersName,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: message['sender_id'] == currentUserId
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
            child: chekBLUser
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
                          onPressed: widget.isMultiConversation
                              ? sendNewMultiMessage
                              : _sendMessage,
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
