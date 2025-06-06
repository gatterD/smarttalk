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

  Future<String> getCurrentIp() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'] as String;
      }
      throw Exception('Failed to get IP: ${response.statusCode}');
    } catch (e) {
      throw Exception('IP detection error: $e');
    }
  }

  Future<bool> checkCorporateIp(String ip) async {
    const allowedSubnets = ['192.168.0.', '10.0.0.', '5.18.96.'];
    return allowedSubnets.any((subnet) => ip.startsWith(subnet));
  }

  Future<bool> autoLoginByIp() async {
    final ip = await getCurrentIp();
    final isCorporate = await checkCorporateIp(ip);

    if (isCorporate) {
      return _getUserByIp(ip);
    }
    throw Exception('Access denied: Not corporate IP');
  }

  Future<bool> _getUserByIp(String ip) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_IP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'PC_IP': ip,
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
        final username = data['username'];

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
