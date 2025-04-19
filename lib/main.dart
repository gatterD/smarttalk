import 'package:flutter/material.dart';
import 'package:smarttalk/features/SmartTalkApp/SmartTalkApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repository/BlackListRepository.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(RepositoryProvider(
    create: (context) => BlackListRepository(),
    child: SmartTalkApp(isLoggedIn: token != null),
  ));
}
