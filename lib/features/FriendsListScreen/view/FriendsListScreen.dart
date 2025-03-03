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
  List<dynamic> friends = [];
  String? currentUserID;
  List<dynamic> pinnedFriends = [];
  List<dynamic> pinnedFriendsList = [];
  List<dynamic> sortedFriends = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('id'); // Получаем ID текущего пользователя
    if (userID != null) {
      setState(() {
        currentUserID = userID;
      });
      await fetchFriends();
      await fetchPinnedFriends();
      List<dynamic> filteredFriends = friends
          .where((friend) => !pinnedFriendsList.contains(friend))
          .toList();
      sortedFriends = [...pinnedFriendsList, ...filteredFriends];
      debugPrint(sortedFriends.toString());
    }
  }

  Future<void> fetchPinnedFriends() async {
    if (currentUserID == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('BASEURL')}/pinned/$currentUserID/conversations'),
      );

      debugPrint(response.body);
      if (response.statusCode == 200) {
        setState(() {
          pinnedFriends = jsonDecode(response.body);
          pinnedFriendsList = pinnedFriends.map((id) {
            return friends.firstWhere((friend) => friend["id"] == id,
                orElse: () => null);
          }).toList();
        });
      } else {
        throw Exception(
            'Ошибка загрузки списка друзей (Код: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Ошибка сети: $e');
    }
  }

  Future<void> fetchFriends() async {
    if (currentUserID == null) return;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASEURL')}/users/$currentUserID/friends'),
      );

      if (response.statusCode == 200) {
        setState(() {
          friends = jsonDecode(response.body);
        });
      } else {
        throw Exception(
            'Ошибка загрузки списка друзей (Код: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Ошибка сети: $e');
    }
  }

  Future<void> _pinConv(String friendId) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASEURL')}/pinned'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': currentUserID, 'friendId': friendId}),
      );

      debugPrint('📡 Ответ сервера: ${response.statusCode}');
      debugPrint('📡 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        // Обновляем состояние и перезагружаем данные
        setState(() {
          // Добавляем friendId в список pinnedFriends
          pinnedFriends.add(friendId);
        });

        // Перезагружаем данные
        await fetchFriends();
        await fetchPinnedFriends();

        // Обновляем sortedFriends
        List<dynamic> filteredFriends = friends
            .where((friend) => !pinnedFriends.contains(friend['id']))
            .toList();
        setState(() {
          sortedFriends = [...pinnedFriendsList, ...filteredFriends];
        });
      } else {
        throw Exception(
            'Ошибка загрузки списка друзей (Код: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Ошибка сети: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('id');
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
      body: RefreshIndicator(
        onRefresh: fetchFriends, // Метод для обновления данных
        child: sortedFriends.isEmpty
            ? Center(
                child: sortedFriends.isEmpty
                    ? Text(
                        'You have no contacts :(',
                        style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    : CircularProgressIndicator(),
              )
            : ListView.separated(
                itemCount: sortedFriends.length,
                itemBuilder: (context, index) {
                  final isPinned =
                      pinnedFriends.contains(sortedFriends[index]['id']);
                  return ListTile(
                    leading: CircleAvatar(
                        child: Text(sortedFriends[index]['username'][0])),
                    title: Text(sortedFriends[index]['username'],
                        style: theme.textTheme.labelMedium),
                    subtitle: Text(
                      'ID: ${sortedFriends[index]['id']}',
                      style: theme.textTheme.labelSmall,
                    ),
                    trailing: isPinned
                        ? Icon(Icons.push_pin_rounded)
                        : IconButton(
                            onPressed: () {
                              _pinConv(sortedFriends[index]['id'].toString());
                            },
                            icon: Icon(
                              Icons.push_pin_outlined,
                              color: Colors.white,
                            )),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersMessageScreen(
                            usersName: sortedFriends[index]['username'],
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              ),
      ),
    );
  }
}
