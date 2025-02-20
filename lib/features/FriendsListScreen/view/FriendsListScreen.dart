import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/features/UsersMessageScreen/view/UsersMessageScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smarttalk/theme/theme.dart';
import '../../AutorisationScreen/Autorisation.dart';

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
    fetchUsers();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    setState(() {
      currentUsername = username;
    });
  }

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('${dotenv.get('BASEURL')}/users'));
    if (response.statusCode == 200) {
      List<dynamic> allUsers = jsonDecode(response.body);

      setState(() {
        users = allUsers
            .where((user) => user['username'] != currentUsername)
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
        title: Text('SmartTalk'),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: users.isEmpty
                  ? Text(
                      'You have no contact`s :(',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  : CircularProgressIndicator(),
            )
          : ListView.separated(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading:
                      CircleAvatar(child: Text(users[index]['username'][0])),
                  title: Text(users[index]['username'],
                      style: theme.textTheme.labelMedium),
                  subtitle: Text(
                    'ID: ${users[index]['id']}',
                    style: theme.textTheme.labelSmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersMessageScreen(
                          usersName: users[index]['username'],
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
