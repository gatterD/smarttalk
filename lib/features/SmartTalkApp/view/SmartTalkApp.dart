import 'package:flutter/material.dart';
import 'package:smarttalk/features/AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/FriendsListScreen/FriendsList.dart';
import 'package:smarttalk/provider/ThemeProvider.dart';
import 'package:smarttalk/router/router.dart';
import 'package:provider/provider.dart';

class SmartTalkApp extends StatelessWidget {
  final bool isLoggedIn;

  const SmartTalkApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      home: isLoggedIn ? FriendsListScreen() : AutorisationScreen(),
      theme: themeProvider.currentTheme,
      routes: router,
    );
  }
}
