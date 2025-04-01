import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smarttalk/theme/theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../AutorisationScreen/Autorisation.dart';

class FriendsListScreen extends StatefulWidget {
  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<dynamic> friends = [];
  String? currentUserID;
  String? currentUsername;
  List<dynamic> pinnedFriends = [];
  List<dynamic> pinnedFriendsList = [];
  List<dynamic> sortedFriends = [];
  List<dynamic> otherConversations = [];
  List<dynamic> otherConversationsIDs = [];
  List<int> friendsIDs = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('id');
    final username = prefs.getString('username');
    if (userID != null) {
      setState(() {
        currentUserID = userID;
        currentUsername = username;
      });
      await fetchFriends();
      await fetchPinnedFriends();
      await fetchOtherConv();
      await _getFriendsIds();
      List<dynamic> filteredFriends = friends
          .where((friend) => !pinnedFriendsList.contains(friend))
          .toList();
      sortedFriends = [...pinnedFriendsList, ...filteredFriends];
      await getOtherConversationsByID();
      sortedFriends = [
        ...pinnedFriendsList,
        ...filteredFriends,
        ...otherConversations
      ];
    }
  }

  Future<void> getOtherConversationsByID() async {
    for (var friend in sortedFriends) {
      if (otherConversationsIDs.contains(friend['id'].toString())) {
        otherConversationsIDs.remove(friend['id'].toString());
      }
    }
    if (otherConversationsIDs.isNotEmpty) {
      otherConversations.clear();
      for (var ID in otherConversationsIDs) {
        try {
          final response = await http.get(
            Uri.parse('${dotenv.get('BASEURL')}/user/$ID'),
          );

          if (response.statusCode == 200) {
            setState(() {
              otherConversations.add(jsonDecode(response.body));
            });
          } else {
            throw Exception(
                'Ошибка загрузки списка друзей (Код: ${response.statusCode})');
          }
        } catch (e) {
          debugPrint('❌ Ошибка сети: $e');
        }
      }
    }
  }

  Future<void> fetchPinnedFriends() async {
    if (currentUserID == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.get('BASEURL')}/pinned/$currentUserID/conversations'),
      );
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

  Future<void> fetchOtherConv() async {
    if (currentUserID == null) return;

    try {
      final response = await http.get(
        Uri.parse('${dotenv.get('BASEURL')}/conversation/$currentUserID'),
      );

      if (response.statusCode == 200) {
        setState(() {
          otherConversations = jsonDecode(response.body);
        });

        for (var conv in otherConversations) {
          if (conv['user1_id'].toString() == currentUserID) {
            setState(() {
              otherConversationsIDs.add(conv['user2_id'].toString());
            });
          } else if (conv['user2_id'].toString() == currentUserID) {
            setState(() {
              otherConversationsIDs.add(conv['user1_id'].toString());
            });
          }
        }
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

  Future<void> _getFriendsIds() async {
    for (var friend in friends) {
      friendsIDs.add(await friend['id']);
    }
  }

  Future<void> delConversation(String friendID) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.get('BASEURL')}/delete/conversation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'friendID': friendID, 'userID': currentUserID}),
      );
      if (response.statusCode == 200) {
        bool chekFindNotFriend = true;
        for (var friend in friends) {
          if (friend['id'].toString() == friendID) {
            chekFindNotFriend = true;
          } else {
            chekFindNotFriend = false;
            break;
          }
        }
        if (!chekFindNotFriend) {
          setState(() {
            otherConversations.removeWhere(
                (conversation) => conversation['id'].toString() == friendID);
          });
          List<dynamic> filteredFriends = friends
              .where((friend) => !pinnedFriendsList.contains(friend))
              .toList();
          setState(() {
            sortedFriends = [
              ...pinnedFriendsList,
              ...filteredFriends,
              ...otherConversations
            ];
          });
        } else {
          setState(() {
            friends.removeWhere(
                (conversation) => conversation['id'].toString() == friendID);
          });
          List<dynamic> filteredFriends = friends
              .where((friend) => !pinnedFriendsList.contains(friend))
              .toList();
          setState(() {
            sortedFriends = [
              ...pinnedFriendsList,
              ...filteredFriends,
              ...otherConversations
            ];
          });
        }
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

      if (response.statusCode == 200) {
        setState(() {
          pinnedFriends.add(friendId);
        });

        await fetchFriends();
        await fetchPinnedFriends();
        List<dynamic> filteredFriends = friends
            .where((friend) => !pinnedFriendsList.contains(friend))
            .toList();

        setState(() {
          sortedFriends = [
            ...pinnedFriendsList,
            ...filteredFriends,
            ...otherConversations
          ];
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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUsername ?? 'Загрузка...',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUsername != null && currentUsername!.isNotEmpty
                      ? currentUsername![0].toUpperCase()
                      : '?',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Настройки'),
              onTap: () {
                // Навигация к экрану настроек
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Создание беседы'),
              onTap: () {
                Navigator.pushNamed(context, '/chat-creation');
              },
            ),
            ListTile(
              leading: Icon(Icons.no_accounts_sharp),
              title: Text('Черный список'),
              onTap: () {
                Navigator.pushNamed(context, '/black_list');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Выйти'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('SmartTalk'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
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
        onRefresh: fetchFriends,
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
                      pinnedFriends.contains(sortedFriends[index]["id"]);
                  return Slidable(
                    key: ValueKey(sortedFriends[index]['id']),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        friendsIDs.contains(sortedFriends[index]['id'])
                            ? SlidableAction(
                                onPressed: (context) {
                                  _pinConv(
                                      sortedFriends[index]['id'].toString());
                                },
                                backgroundColor: Colors.blue,
                                icon: Icons.push_pin,
                                label: 'Закрепить',
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Text(
                                  'Not your friend.',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                        SlidableAction(
                          onPressed: (context) {
                            delConversation(
                                sortedFriends[index]['id'].toString());
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Удалить',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child:
                            sortedFriends[index]['username'] == currentUsername
                                ? Icon(Icons.bookmark_border)
                                : Icon(Icons.person),
                      ),
                      title: sortedFriends[index]['username'] == currentUsername
                          ? Text('Favorite', style: theme.textTheme.labelMedium)
                          : Text(sortedFriends[index]['username'],
                              style: theme.textTheme.labelMedium),
                      subtitle: Text(
                        'ID: ${sortedFriends[index]['id']}',
                        style: theme.textTheme.labelSmall,
                      ),
                      trailing: isPinned
                          ? Icon(Icons.push_pin_rounded)
                          : friendsIDs.contains(sortedFriends[index]['id'])
                              ? IconButton(
                                  onPressed: () {
                                    _pinConv(
                                        sortedFriends[index]['id'].toString());
                                  },
                                  icon: Icon(
                                    Icons.push_pin_outlined,
                                    color: Colors.white,
                                  ))
                              : Icon(Icons.no_accounts),
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
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              ),
      ),
    );
  }
}
