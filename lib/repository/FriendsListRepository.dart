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

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
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
