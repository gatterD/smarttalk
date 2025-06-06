import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import '../../../services/BlackListConfiramationDialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarttalk/features/BlackListScreen/bloc/BlackListBloc.dart';
import 'package:smarttalk/repository/BlackListRepository.dart';
import 'package:smarttalk/provider/ThemeProvider.dart'; // Import ThemeProvider

class BlackListScreen extends StatefulWidget {
  const BlackListScreen({super.key});

  @override
  State<BlackListScreen> createState() => _BlackListScreenState();
}

class _BlackListScreenState extends State<BlackListScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Черный список',
              style: themeProvider.currentTheme.textTheme.headlineLarge,
            ),
          ),
          body: BlocProvider(
            create: (context) => BlackListBloc(
              RepositoryProvider.of<BlackListRepository>(context),
            )
              ..add(LoadBLCurrentUserID())
              ..add(LoadBlackListEvent()),
            child: BlocBuilder<BlackListBloc, BlackListState>(
              builder: (context, state) {
                if (state is BlackListLoadingState ||
                    state is BlackListLoadingUserState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BlackListErrorState) {
                  return Center(
                    child: Text(
                      'Ошибка: ${state.error}',
                      style: themeProvider.currentTheme.textTheme.bodyMedium,
                    ),
                  );
                } else if (state is BlackListLoadedState) {
                  return state.users.isEmpty
                      ? Center(
                          child: Text(
                            'Черный список пуст',
                            style: themeProvider
                                .currentTheme.textTheme.labelMedium
                                ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            var user = state.users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                user['username'],
                                style: themeProvider
                                    .currentTheme.textTheme.labelMedium,
                              ),
                              subtitle: Text(
                                'ID: ${user['id']}',
                                style: themeProvider
                                    .currentTheme.textTheme.labelSmall,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  showRemoveConfirmationDialog(
                                    context: context,
                                    user: user,
                                    onConfirm: () {
                                      context.read<BlackListBloc>().add(
                                          RemoveFromBlackListEvent(
                                              blockedUserId: user['id']));
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                        );
                }
                return const Center(child: Text('Нет данных'));
              },
            ),
          ),
        );
      },
    );
  }
}
