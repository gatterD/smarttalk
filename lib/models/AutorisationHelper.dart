import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smarttalk/models/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/services/EncryptionService.dart';

class AuthService {
  EncryptionService _encryptionService = new EncryptionService();
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
        body: jsonEncode({
          'username': username,
          'password': _encryptionService.encrypt(password)
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey('token') || data['token'] == null) {
          debugPrint("Ошибка: сервер не вернул токен");
          return false;
        }
        final token = data['token'];
        final currID = data['currId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setString('id', currID.toString());

        return true;
      } else {
        debugPrint("Ошибка входа: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      debugPrint("Ошибка сети: $error");
      return false;
    }
  }
}
