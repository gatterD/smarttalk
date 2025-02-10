import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarttalk/models/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.get('BASEURL');

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<String?> login(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
    return null;
  }
}
