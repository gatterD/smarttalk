import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlackListRepository {
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<List<dynamic>> fetchBlackList(String userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASEURL')}/black_list/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки списка (Код: ${response.statusCode})');
    }
  }

  Future<dynamic> fetchUser(int userId) async {
    final response = await http.get(
      Uri.parse('${dotenv.get('BASEURL')}/user/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Ошибка загрузки пользователя (Код: ${response.statusCode})');
    }
  }

  Future<void> deleteFromBlackList({
    required int userBLID,
    required String currentUserID,
  }) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/getOut/black_list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'getOutUser': userBLID, 'userID': currentUserID}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Ошибка удаления из списка (Код: ${response.statusCode})');
    }
  }
}
