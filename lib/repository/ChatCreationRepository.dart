import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class ChatCreationRepository {
  final String baseUrl = dotenv.get('BASEURL');

  Future<String?> loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('id');
    return userID;
  }

  Future<List<dynamic>> fetchFriends(String userID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userID/friends'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Ошибка загрузки списка друзей: $e");
    }
    return [];
  }

  Future<void> chatCreate(
      TextEditingController chatNameController,
      String currentUserId,
      List<dynamic> addedUsers,
      BuildContext context) async {
    try {
      final chatName = chatNameController.text;
      final chatIDS = [int.parse(currentUserId)];
      for (var item in addedUsers) {
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
}
