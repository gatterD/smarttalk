import 'dart:convert';

import 'package:smarttalk/models/User.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final http.Client client;
  final String baseUrl = dotenv.get('BASEURL');

  UserRepository({required this.client});

  Future<List<User>> searchUsers(String query) async {
    final response = await client.get(
      Uri.parse('$baseUrl/users?search=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
