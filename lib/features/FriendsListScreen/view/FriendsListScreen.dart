import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';
import 'package:smarttalk/theme/theme.dart';
import '../../AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/FriendsListScreen/bloc/FriendsListBloc.dart';
import 'package:smarttalk/repository/FriendsListRepository.dart';
import 'package:smarttalk/theme/colors.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FriendsBloc(FriendsRepository())..add(LoadFriendsEvent()),
      child: Scaffold(
        drawer: const FriendsDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('SmartTalk'),
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
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        body: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoadingState) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.drawerDivider),
                ),
              );
            } else if (state is FriendsErrorState) {
              return Center(
                child: Text(
                  state.error,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.red[200]),
                ),
              );
            } else if (state is FriendsLoadedState) {
              return FriendsListView(state: state);
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class FriendsDrawer extends StatelessWidget {
  const FriendsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        String username = '';
        if (state is FriendsLoadedState) {
          username = state.currentUsername;
        }

        return Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
          ),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  username.isNotEmpty ? username : 'Загрузка...',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                accountEmail: null,
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightText,
                        AppColors.accent,
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.lightText,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.background,
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
                    ),
                    _buildDrawerItem(
                      icon: Icons.forum_outlined,
                      text: 'Создание беседы',
                      onTap: () =>
                          Navigator.pushNamed(context, '/chat-creation'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.no_accounts_sharp,
                      text: 'Черный список',
                      onTap: () => Navigator.pushNamed(context, '/black_list'),
                    ),
                    const Divider(
                      color: AppColors.drawerDivider,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.backgroundLight,
      ),
      title: Text(
        text,
        style: theme.textTheme.titleMedium,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 24,
    );
  }
}

class FriendsListView extends StatelessWidget {
  final FriendsLoadedState state;

  const FriendsListView({super.key, required this.state});

  bool isMultiUser(String username) {
    return state.multiConversations.any((conv) => conv['username'] == username);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColors.background,
      color: AppColors.lightText,
      onRefresh: () async =>
          context.read<FriendsBloc>().add(LoadFriendsEvent()),
      child: state.sortedFriends.isEmpty
          ? Center(
              child: Text(
                'You have no contacts :(',
                style: theme.textTheme.labelMedium?.copyWith(
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
                          backgroundColor: Colors.red[400]!,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Удалить',
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.background,
                            AppColors.backgroundLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                                AppColors.primary,
                                AppColors.accent,
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
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${friend['id']}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        trailing: isPinned
                            ? const Icon(
                                Icons.push_pin,
                                color: Color.fromRGBO(36, 123, 160, 1),
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
                                    icon: const Icon(
                                      Icons.push_pin_outlined,
                                      color: AppColors.drawerDivider,
                                    ),
                                  )
                                : const Icon(
                                    Icons.no_accounts,
                                    color: AppColors.drawerDivider,
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
