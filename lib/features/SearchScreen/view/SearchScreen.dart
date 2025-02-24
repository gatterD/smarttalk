import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/theme.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  Set<int> _friends = {}; // Список ID друзей
  bool _isLoading = false;
  String? _currentUserId; // ID текущего пользователя
  final String baseUrl = dotenv.get('BASEURL');

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  /// Загружаем ID пользователя из SharedPreferences
  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');

    if (userId != null) {
      setState(() {
        _currentUserId = userId;
      });
      _fetchFriends(userId); // Загружаем список друзей
    }
  }

  /// Загружаем список друзей текущего пользователя
  Future<void> _fetchFriends(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/friends'),
      );

      if (response.statusCode == 200) {
        List<dynamic> friends = jsonDecode(response.body);
        setState(() {
          _friends = friends.map<int>((f) => f['id'] as int).toSet();
          _friends.add(int.parse(_currentUserId!));
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки списка друзей: $e");
    }
  }

  /// Добавляем пользователя в друзья
  Future<bool> _addFriend(int friendId) async {
    if (_currentUserId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_currentUserId/friends'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"friendId": friendId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _friends.add(friendId);
        });
        return true;
      }
    } catch (e) {
      debugPrint("Ошибка при добавлении друга: $e");
      return false;
    }
    return false;
  }

  /// Поиск пользователей по запросу
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
      body: _currentUserId == null
          ? Center(
              child: Text("Ошибка: не удалось загрузить данные пользователя"))
          : _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isFriend = _friends.contains(user['id']);

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
                      trailing: isFriend
                          ? Icon(Icons.check,
                              color:
                                  Colors.green) // Галочка, если уже в друзьях
                          : IconButton(
                              icon: Icon(Icons.person_add, color: Colors.blue),
                              onPressed: () async {
                                bool success = await _addFriend(user['id']);
                                if (success) {
                                  setState(() {
                                    _friends.add(user[
                                        'id']); // Добавляем пользователя в друзья
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${user['username']} добавлен в друзья')),
                                  );
                                }
                              },
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
