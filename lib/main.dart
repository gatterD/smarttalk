import 'package:flutter/material.dart';
import 'package:smarttalk/features/FriendsListScreen/bloc/FriendsListBloc.dart';
import 'package:smarttalk/features/SmartTalkApp/SmartTalkApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarttalk/features/UserSettingsScreen/bloc/UserSettingsBloc.dart';
import 'package:smarttalk/repository/FriendsListRepository.dart';
import 'package:smarttalk/repository/UserSettingsRepository.dart';
import 'repository/BlackListRepository.dart';
import 'repository/SearchRepository.dart';
import 'features/SearchScreen/bloc/SearchBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => BlackListRepository(),
        ),
        RepositoryProvider(
          create: (context) => SearchRepository(),
        ),
        RepositoryProvider(
          create: (context) => UserSettingsRepository(),
        ),
        // Add FriendsRepository if you have one
        RepositoryProvider(
          create: (context) => FriendsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SearchBloc(
              context.read<SearchRepository>(),
            )..add(LoadingUserIDSearchEvent()),
          ),
          BlocProvider(
            create: (context) => UserSettingsBloc(
              repository: context.read<UserSettingsRepository>(),
            ),
          ),
          // Add FriendsBloc here
          BlocProvider(
            create: (context) => FriendsBloc(
              context.read<FriendsRepository>(), // If you have one
            ),
          ),
        ],
        child: ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeProvider.currentTheme,
                home: SmartTalkApp(isLoggedIn: token != null),
              );
            },
          ),
        ),
      ),
    ),
  );
}
