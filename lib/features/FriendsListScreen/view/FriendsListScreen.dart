import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/features/UsersMessageScreen/view/UsersMessageScreen.dart';

import '../../AutorisationScreen/view/AutorisationScreen.dart';

class FriendsListScreen extends StatefulWidget {
  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<dynamic> users = [];
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername =
          prefs.getString('username'); // Получаем имя пользователя
    });
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/users'));
    if (response.statusCode == 200) {
      List<dynamic> allUsers = jsonDecode(response.body);

      setState(() {
        users = allUsers
            .where((user) => user['userName'] != currentUsername)
            .toList();
      });
    } else {
      throw Exception('Ошибка загрузки пользователей');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AutorisationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Список пользователей'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          )
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: users.isEmpty && currentUsername != null
                  ? Text(
                      'У вас пока нет контактов :(',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  : CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index]['userName']),
                  subtitle: Text('ID: ${users[index]['id']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersMessageScreen(
                          usersName: users[index]['userName'],
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
            ),
    );
  }
}
