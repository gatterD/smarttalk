import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarttalk/models/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = dotenv.get('BASEURL');

  Future<bool> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey('token') || data['token'] == null) {
          print("Ошибка: сервер не вернул токен");
          return false;
        }

        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);

        return true;
      } else {
        print("Ошибка входа: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      print("Ошибка сети: $error");
      return false;
    }
  }
}
