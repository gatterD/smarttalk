import 'package:flutter/material.dart';
import 'package:smarttalk/features/SmartTalkApp/SmartTalkApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/BlackListRepository.dart';
import 'repository/SearchRepository.dart';
import 'features/SearchScreen/bloc/SearchBloc.dart'; // Добавьте этот импорт

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider(
        create: (context) => BlackListRepository(),
      ),
      RepositoryProvider(
        create: (context) => SearchRepository(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SearchBloc(
            context.read<SearchRepository>(),
          )..add(LoadingUserIDSearchEvent()), // Инициализация при старте
        ),
      ],
      child: SmartTalkApp(isLoggedIn: token != null),
    ),
  ));
}
