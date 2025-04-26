import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersMessageRepository {
  final baseUrl = dotenv.get('BASEURL');

  Future<bool> chekBlackList(
      List<dynamic> black_list, int currentUserId) async {
    for (var blacklistItem in black_list) {
      if (blacklistItem == currentUserId) {
        return true;
      }
    }
    return false;
  }

  Future<List<dynamic>> getBlackList(String convID) async {
    final response = await http.get(
      Uri.parse('$baseUrl/black_list/$convID'),
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final decodedData = jsonDecode(response.body);
          return decodedData is List ? decodedData : [];
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
          return [];
        }
      }
    } else {
      debugPrint('Failed to load black list: ${response.statusCode}');
    }
    return [];
  }

  Future<int> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String currentUsername = prefs.getString('username') ?? '';
    if (currentUsername.isNotEmpty) {
      int currentUserId = await getUserIdByUsername(currentUsername);
      return currentUserId;
    }
    return 0;
  }

  Future<int> getUserIdByUsername(String name) async {
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

  Future<int> initializeConversation(int currentUserId, int convID) async {
    final convId = await getOrCreateConversation(
      currentUserId.toString(),
      convID.toString(),
    );
    return convId;
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

  Future<List<dynamic>> loadMessages(int conversationId) async {
    final response = await http
        .get(Uri.parse('${dotenv.get('BASEURL')}/messages/$conversationId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<void> sendMessage(
      String content, int conversationId, int currentUserId, int convID) async {
    if (content.isEmpty) return;
    final messageText = content;

    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': convID,
        'content': messageText,
      }),
    );

    if (response.statusCode == 201) {
      await loadMessages(conversationId);
    } else {
      debugPrint('Ошибка отправки сообщения');
    }
  }

  Future<List<dynamic>> fetchMultiConvMessages(int convID) async {
    try {
      final response = await http
          .get(Uri.parse('${dotenv.get('BASEURL')}/multi/chat/${convID}'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Не удалось получить ID: $e");
    }
    return [];
  }

  Future<void> sendNewMultiMessage(String content, int convID,
      int currentUserId, String currentUsername) async {
    if (content.isEmpty) return;
    final messageText = content;

    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/multi/chat/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': convID,
        'sender_id': currentUserId,
        'content': messageText,
        'sender_name': currentUsername,
      }),
    );

    if (response.statusCode == 200) {
      await fetchMultiConvMessages(convID);
    } else {
      debugPrint('Ошибка отправки сообщения');
    }
  }
}
