import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterRepository {
  final baseUrl = dotenv.get('BASEURL');

  Future<int> getUserIdByUsername(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/name/$name'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Ошибка загрузки ID пользователя');
    }
  }

  Future<int?> CreateConversation(String user1Id, String user2Id) async {
    final createResponse = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'user1_id': user1Id, 'user2_id': user2Id}),
    );
    if (createResponse.statusCode == 201) {
      return jsonDecode(createResponse.body)['id'];
    }
    return null;
  }
}
