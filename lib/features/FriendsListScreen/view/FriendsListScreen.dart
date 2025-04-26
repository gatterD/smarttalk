import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';
import '../../AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/FriendsListScreen/bloc/FriendsListBloc.dart';
import 'package:smarttalk/repository/FriendsListRepository.dart';
import 'package:smarttalk/provider/ThemeProvider.dart'; // Import ThemeProvider

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FriendsBloc(FriendsRepository())..add(LoadFriendsEvent()),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            drawer: const FriendsDrawer(),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'SmartTalk',
                style: themeProvider.currentTheme.textTheme.headlineLarge,
              ),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                )
              ],
            ),
            body: BlocBuilder<FriendsBloc, FriendsState>(
              builder: (context, state) {
                if (state is FriendsLoadingState) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          themeProvider.currentColorTheme.drawerDivider),
                    ),
                  );
                } else if (state is FriendsErrorState) {
                  return Center(
                    child: Text(
                      state.error,
                      style: themeProvider.currentTheme.textTheme.labelMedium
                          ?.copyWith(
                              color: themeProvider.currentColorTheme.red),
                    ),
                  );
                } else if (state is FriendsLoadedState) {
                  return FriendsListView(
                      state: state, themeProvider: themeProvider);
                }
                return Container();
              },
            ),
          );
        },
      ),
    );
  }
}

class FriendsDrawer extends StatelessWidget {
  const FriendsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            String username = '';
            if (state is FriendsLoadedState) {
              username = state.currentUsername;
            }

            return Drawer(
              backgroundColor: themeProvider.currentColorTheme.white,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      username.isNotEmpty ? username : 'Загрузка...',
                      style: themeProvider.currentTheme.textTheme.labelMedium
                          ?.copyWith(
                        fontSize: 20,
                        color: themeProvider.currentColorTheme.white,
                      ),
                    ),
                    accountEmail: null,
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColorTheme.lightText,
                            themeProvider.currentColorTheme.accent,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor:
                            themeProvider.currentColorTheme.mediumbackground,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: themeProvider
                              .currentTheme.textTheme.headlineLarge,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeProvider.currentColorTheme.primary,
                          themeProvider.currentColorTheme.background,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          icon: Icons.settings,
                          text: 'Настройки',
                          onTap: () {},
                          themeProvider: themeProvider,
                        ),
                        _buildDrawerItem(
                          icon: Icons.forum_outlined,
                          text: 'Создание беседы',
                          onTap: () =>
                              Navigator.pushNamed(context, '/chat-creation'),
                          themeProvider: themeProvider,
                        ),
                        _buildDrawerItem(
                          icon: Icons.no_accounts_sharp,
                          text: 'Черный список',
                          onTap: () =>
                              Navigator.pushNamed(context, '/black_list'),
                          themeProvider: themeProvider,
                        ),
                        Divider(
                          color: themeProvider.currentColorTheme.drawerDivider,
                          indent: 16,
                          endIndent: 16,
                        ),
                        _buildDrawerItem(
                          icon: Icons.exit_to_app,
                          text: 'Выйти',
                          onTap: () {
                            context.read<FriendsBloc>().add(LogoutEvent());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AutorisationScreen()),
                            );
                          },
                          themeProvider: themeProvider,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: themeProvider.currentColorTheme.backgroundLight,
      ),
      title: Text(
        text,
        style: themeProvider.currentTheme.textTheme.titleMedium,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 24,
    );
  }
}

class FriendsListView extends StatelessWidget {
  final FriendsLoadedState state;
  final ThemeProvider themeProvider;

  const FriendsListView(
      {super.key, required this.state, required this.themeProvider});

  bool isMultiUser(String username) {
    return state.multiConversations.any((conv) => conv['username'] == username);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<FriendsBloc>().add(LoadFriendsEvent()),
      child: state.sortedFriends.isEmpty
          ? Center(
              child: Text(
                'You have no contacts :(',
                style:
                    themeProvider.currentTheme.textTheme.labelMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sortedFriends.length,
              itemBuilder: (context, index) {
                final friend = state.sortedFriends[index];
                final isPinned = state.pinnedFriends.contains(friend["id"]);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Slidable(
                    key: ValueKey(friend['id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            context.read<FriendsBloc>().add(
                                  DeleteConversationEvent(
                                      friend['id'].toString()),
                                );
                          },
                          backgroundColor: themeProvider.currentColorTheme.red,
                          icon: Icons.delete,
                          label: 'Добавить в ЧС',
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.currentColorTheme.background,
                            themeProvider.currentColorTheme.backgroundLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.currentColorTheme.black,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.currentColorTheme.primary,
                                themeProvider.currentColorTheme.accent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: friend['username'] == state.currentUsername
                                ? const Icon(Icons.bookmark, size: 20)
                                : Text(
                                    friend['username'][0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          friend['username'] == state.currentUsername
                              ? 'Favorite'
                              : friend['username'],
                          style: themeProvider
                              .currentTheme.textTheme.labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${friend['id']}',
                          style: themeProvider.currentTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        trailing: isPinned
                            ? Icon(
                                Icons.push_pin,
                                color: themeProvider
                                    .currentColorTheme.mediumbackground,
                              )
                            : state.sortedFriends
                                    .any((f) => f['id'] == friend['id'])
                                ? IconButton(
                                    onPressed: () {
                                      context.read<FriendsBloc>().add(
                                            PinConversationEvent(
                                                friend['id'].toString()),
                                          );
                                    },
                                    icon: Icon(
                                      Icons.push_pin_outlined,
                                      color:
                                          themeProvider.currentColorTheme.gray,
                                    ),
                                  )
                                : Icon(
                                    Icons.no_accounts,
                                    color: themeProvider.currentColorTheme.gray,
                                  ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersMessageScreen(
                                usersName: friend['username'],
                                isMultiConversation:
                                    isMultiUser(friend['username']),
                                convID: friend['id'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
            ),
    );
  }
}
