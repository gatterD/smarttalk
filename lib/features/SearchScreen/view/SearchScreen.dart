import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../theme/theme.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  final String baseUrl = dotenv.get('BASEURL');

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _users = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?query=$query'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Ошибка при поиске пользователей');
      }
    } catch (e) {
      debugPrint("Ошибка: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Поиск...",
              hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
            ),
            onChanged: (value) => _searchUsers(value),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user['username'][0])),
                  title: Text(
                    user['username'],
                    style: theme.textTheme.labelMedium,
                  ),
                  subtitle: Text(
                    "ID: ${user['id']}",
                    style: theme.textTheme.labelSmall,
                  ),
                  onTap: () {
                    debugPrint("Выбран пользователь: ${user['username']}");
                  },
                );
              },
            ),
    );
  }
}
