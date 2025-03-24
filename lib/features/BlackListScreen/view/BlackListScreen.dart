import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/theme/theme.dart';

class BlackListScreen extends StatefulWidget {
  const BlackListScreen({super.key});

  @override
  State<BlackListScreen> createState() => _BlackListScreenState();
}

class _BlackListScreenState extends State<BlackListScreen> {
  String? currentUserID;
  List<dynamic> blackListIDs = [];
  List<dynamic> blackListUsers = [];
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> deleteFromBL(int userBLID) async {
    final response = await http.post(
      Uri.parse('${dotenv.get('BASEURL')}/getOut/black_list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'getOutUser': userBLID, 'userID': currentUserID}),
    );

    if (response.statusCode == 200) {
      setState(() {
        blackListUsers.removeWhere((userID) => userID['id'] == userBLID);
      });
    } else {
      throw Exception(
          'Ошибка загрузки списка друзей (Код: ${response.statusCode})');
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('id');
    if (userID != null) {
      setState(() {
        currentUserID = userID;
      });
    }
    await _fetchBlackList();
  }

  Future<void> _fetchBlackList() async {
    if (currentUserID == null) return;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASEURL')}/black_list/$currentUserID'),
      );

      if (response.statusCode == 200) {
        setState(() {
          blackListIDs = jsonDecode(response.body);
        });

        for (var ID in blackListIDs) {
          try {
            final response = await http.get(
              Uri.parse('${dotenv.get('BASEURL')}/user/$ID'),
            );

            if (response.statusCode == 200) {
              setState(() {
                blackListUsers.add(jsonDecode(response.body));
              });
            } else {
              throw Exception(
                  'Ошибка загрузки списка (Код: ${response.statusCode})');
            }
          } catch (e) {
            debugPrint('❌ Ошибка сети: $e');
          }
        }
      } else {
        throw Exception('Ошибка загрузки списка (Код: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Ошибка сети: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Черный список'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBlackList,
        child: blackListUsers.isEmpty
            ? Center(
                child: Text(
                  'Черный список пуст',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: blackListUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      blackListUsers[index]['username'],
                      style: theme.textTheme.labelMedium,
                    ),
                    subtitle: Text(
                      'ID: ${blackListUsers[index]['id']}',
                      style: theme.textTheme.labelSmall,
                    ),
                    trailing: ElevatedButton.icon(
                      icon: Icon(Icons.person_remove, size: 18),
                      label: Text('Удалить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        _showRemoveConfirmationDialog(
                            context, blackListUsers[index]);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              ),
      ),
    );
  }

  void _showRemoveConfirmationDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтверждение'),
          content: Text(
              'Вы уверены, что хотите удалить ${user['username']} из черного списка?'),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Удалить'),
              onPressed: () {
                deleteFromBL(user['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
