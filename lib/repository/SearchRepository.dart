import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchRepository {
  final String baseUrl = dotenv.get('BASEURL');

  Future<String?> loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    return userId;
  }

  /// Загружаем список друзей текущего пользователя
  Future<List<dynamic>> fetchFriends(String userID) async {
    List<dynamic> friends = [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userID/friendsids'),
      );

      if (response.statusCode == 200) {
        friends = jsonDecode(response.body);
      }

      return friends;
    } catch (e) {
      debugPrint("Ошибка загрузки списка друзей: $e");
    }
    return [];
  }

  /// Добавляем пользователя в друзья
  Future<bool> addFriend(int friendId, int currentUserId) async {
    if (currentUserId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$currentUserId/friends'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"friendId": friendId}),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint("Ошибка при добавлении друга: $e");
      return false;
    }
    return false;
  }

  /// Поиск пользователей по запросу
  Future<List<dynamic>> searchUsers(
      String query, List<dynamic> black_list) async {
    List<dynamic> users = [];

    if (query.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/search?query=$query'),
      );

      if (response.statusCode == 200) {
        users = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        for (var blUser in black_list) {
          users.removeWhere((user) => user['id'] == blUser);
        }

        return users;
      } else {
        throw Exception('Ошибка при поиске пользователей');
      }
    } catch (e) {
      debugPrint("Ошибка: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchBLUsers(String userID) async {
    List<dynamic> black_list = [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/black_list/$userID'),
      );

      debugPrint(response.body.toString());
      if (response.statusCode == 200) {
        black_list = jsonDecode(response.body);
        return black_list;
      }
    } catch (e) {
      debugPrint("Ошибка загрузки черного списка: $e");
    }
    return [];
  }
}
