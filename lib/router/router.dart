import 'package:flutter/material.dart';
import 'package:smarttalk/features/AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/BlackListScreen/BlackList.dart';
import 'package:smarttalk/features/ChatCreationScreen/ChatCreation.dart';
import 'package:smarttalk/features/FriendsListScreen/friendsList.dart';
import 'package:smarttalk/features/RegisterScreen/Register.dart';
import 'package:smarttalk/features/SearchScreen/Search.dart';
import 'package:smarttalk/features/UserSettingsScreen/UserSettings.dart';
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';

import 'package:shared_preferences/shared_preferences.dart';

final router = {
  '/login': (context) => AutorisationScreen(),
  '/friend_list': (context) => FriendsListScreen(),
  '/register': (context) => RegisterScreen(),
  '/message': (context) => UsersMessageScreen(
        usersName: '',
        isMultiConversation: false,
        convID: 0,
      ),
  '/search': (context) => SearchScreen(),
  '/black_list': (context) => BlackListScreen(),
  '/chat-creation': (context) => ChatCreationScreen(),
  '/settings': (context) => FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); // Или загрузочный экран
          }

          final prefs = snapshot.data!;
          final userId = int.tryParse(prefs.getString('id') ?? '0') ?? 0;

          return UserSettingsScreen(userId: userId);
        },
      ),
};
