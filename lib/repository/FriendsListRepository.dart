import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendsRepository {
  final String baseUrl = dotenv.get('BASEURL');

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<String?> getCurrentUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<List<dynamic>> getBlacklist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/black_list/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Пользователь не найден');
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении черного списка: $e');
    }
  }

  Future<List<dynamic>> deleteBLUsers(
      List<dynamic> ConvList, List<dynamic> BlackList) async {
    try {
      final blackListIds =
          BlackList.map((user) => user['id'].toString()).toSet();

      final filteredList = ConvList.where((user) {
        final userId = user['id'].toString();
        return !blackListIds.contains(userId);
      }).toList();

      return filteredList;
    } catch (e) {
      print('Error filtering users: $e');
      return ConvList;
    }
  }

  Future<List<dynamic>> fetchFriends(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/users/$userId/friends'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load friends (Code: ${response.statusCode})');
  }

  Future<List<dynamic>> fetchPinnedFriends(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/pinned/$userId/conversations'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
        'Failed to load pinned friends (Code: ${response.statusCode})');
  }

  Future<List<dynamic>> fetchOtherConversations(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/conversation/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 204) {
      debugPrint("Нет других переписок");
    }
    throw Exception(
        'Failed to load other conversations (Code: ${response.statusCode})');
  }

  Future<List<dynamic>> fetchMultiConversations(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/multi/conversation/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(
        'Failed to load multi conversations (Code: ${response.statusCode})');
  }

  Future<void> deleteConversation(String userId, String friendId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete/conversation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'friendID': friendId, 'userID': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete conversation (Code: ${response.statusCode})');
    }
  }

  Future<void> pinConversation(String userId, String friendId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pinned'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': userId, 'friendId': friendId}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to pin conversation (Code: ${response.statusCode})');
    }
  }

  Future<void> unpinUser(String currentUserID, String secondID) async {
    final response = await http.post(
      Uri.parse('$baseUrl/unpin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': currentUserID, 'friendId': secondID}),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to pin conversation (Code: ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load user info (Code: ${response.statusCode})');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('id');
  }
}
