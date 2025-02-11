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
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']; // Проверить, не null ли это поле

      if (token == null) {
        throw Exception("Ошибка: сервер не вернул токен");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    } else {
      return false;
    }
  }
}
