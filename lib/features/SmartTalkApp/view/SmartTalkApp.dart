import 'package:flutter/material.dart';
import 'package:smarttalk/features/AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/FriendsListScreen/FriendsList.dart';
import 'package:smarttalk/router/router.dart';
import 'package:smarttalk/theme/theme.dart';

class SmartTalkApp extends StatelessWidget {
  final bool isLoggedIn;

  const SmartTalkApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? FriendsListScreen() : AutorisationScreen(),
      theme: theme,
      routes: router,
    );
  }
}
