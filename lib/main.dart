import 'package:flutter/material.dart';
import 'package:smarttalk/features/SmartTalkApp/SmartTalkApp.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(SmartTalkApp(isLoggedIn: token != null));
}
