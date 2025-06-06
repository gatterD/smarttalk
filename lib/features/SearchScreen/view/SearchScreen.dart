import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';
import 'package:smarttalk/features/SearchScreen/bloc/SearchBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = BlocProvider.of<SearchBloc>(context);
    _searchBloc.add(LoadingUserIDSearchEvent());
    _searchBloc.add(LoadingBlackListSearchEvent());
    _searchBloc.add(LoadingFriendsSearchEvent());
  }

  void _searchUsers(String query) {
    if (query.isNotEmpty) {
      _searchBloc.add(LoadingUsersSearchEvent(query));
    }
  }

  Future<bool> _addFriend(String friendId) async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Container(
              height: 40,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Поиск...",
                  hintStyle:
                      themeProvider.currentTheme.textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(179, 0, 0, 0),
                  ),
                ),
                style: themeProvider.currentTheme.textTheme.bodyMedium,
                onChanged: (value) => _searchUsers(value),
              ),
            ),
          ),
          body: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is ErrorSearchState) {
                return Center(
                  child: Text(
                    "Ошибка: ${state.error}",
                    style: themeProvider.currentTheme.textTheme.labelMedium,
                  ),
                );
              }

              if (state is LoadingSearchState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LoadedInitialSearchState) {
                return Center(
                  child: Text(
                    "Enter search request",
                    style: themeProvider.currentTheme.textTheme.labelLarge,
                  ),
                );
              }

              if (state is LoadedSearchState) {
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    bool isFriend = false;
                    if (state.friends.contains(user['id']) ||
                        user['id'] == state.userID) {
                      isFriend = true;
                    }
                    return ListTile(
                      leading: CircleAvatar(child: Text(user['username'][0])),
                      title: Text(
                        user['username'],
                        style: themeProvider.currentTheme.textTheme.labelMedium,
                      ),
                      subtitle: Text(
                        "ID: ${user['id']}",
                        style: themeProvider.currentTheme.textTheme.labelSmall,
                      ),
                      trailing: isFriend
                          ? Icon(Icons.check, color: Colors.green)
                          : IconButton(
                              icon: Icon(Icons.person_add, color: Colors.blue),
                              onPressed: () async {
                                bool success =
                                    await _addFriend(user['id'].toString());
                                if (success) {
                                  _searchBloc
                                      .add(AddToFriendSearchEvent(user['id']));
                                  _searchBloc.add(LoadingFriendsSearchEvent());

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UsersMessageScreen(
                              usersName: user['username'],
                              isMultiConversation: false,
                              convID: user['id'],
                              messageOnVoiceAssistant: null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return Center(
                child: Text(
                  "Enter search request",
                  style: themeProvider.currentTheme.textTheme.labelLarge,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
