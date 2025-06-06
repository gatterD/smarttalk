import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smarttalk/features/UsersMessageScreen/view/UsersMessageScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smarttalk/features/SearchScreen/view/SearchScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class VoiceAssistant {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final baseUrl = dotenv.get('BASEURL');
  bool _isListening = false;
  List<dynamic> friends = [];
  bool get isListening => _isListening;

  Future<int> getUserIdByUsername(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/name/$name'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Ошибка загрузки ID пользователя');
    }
  }

  void updateFriendsList(List<dynamic> friendsList) {
    debugPrint('Updating friends list with ${friendsList.length} friends');
    if (friendsList.isEmpty) {
      debugPrint('Warning: Friends list is empty');
    }
    friends = friendsList;
  }

  Future<void> startListening(
    BuildContext context, {
    required void Function(String text) onTextRecognized,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Голосовое управление доступно только на мобильных устройствах.')),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('Speech Status: $val'),
      onError: (val) => debugPrint('Speech Error: $val'),
    );
    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (val) {
          if (val.hasConfidenceRating && val.confidence > 0) {
            final command = val.recognizedWords.toLowerCase();
            onTextRecognized(command);
            _handleCommand(context, command);
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  void _handleCommand(BuildContext context, String command) {
    debugPrint('Handling command: $command');
    debugPrint('Current friends list: $friends');

    if (command.isEmpty) {
      debugPrint('Error: Empty command received');
      return;
    }

    if (command.contains('поиск') || command.contains('найти')) {
      debugPrint('Navigating to search screen');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );
    } else if (command.contains('создать чат') ||
        command.contains('новый чат')) {
      debugPrint('Navigating to chat creation');
      Navigator.pushNamed(context, '/chat-creation');
    } else if (command.contains('настройки')) {
      debugPrint('Navigating to settings');
      Navigator.pushNamed(context, '/settings');
    } else if (command.contains('напиши') || command.contains('отправь')) {
      debugPrint('Processing message command');
      final originalCommand = command;
      final lowerCommand = command.toLowerCase();

      List<dynamic> user = _extractUserNameFromCommand(lowerCommand);

      if (user.isNotEmpty && user[0] != null) {
        String username = user[0]['username'].toLowerCase();
        debugPrint('Found user for message: $username');

        int usernameIndex = lowerCommand.indexOf(username);

        if (usernameIndex != -1) {
          String message =
              originalCommand.substring(usernameIndex + username.length).trim();
          debugPrint('Extracted message: $message');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersMessageScreen(
                usersName: user[0]['username'],
                isMultiConversation: user[0]['id'] >= 5000,
                convID: user[0]['id'],
                messageOnVoiceAssistant: message.isNotEmpty ? message : null,
              ),
            ),
          );
        }
      } else {
        debugPrint('No valid user found for message command');
      }
    } else if (command.contains('чат') ||
        command.contains('открой чат') ||
        command.contains('chat') ||
        command.contains('open chat') ||
        command.contains('openchat')) {
      List<dynamic> user = _extractUserNameFromCommand(command);
      if (user.isNotEmpty && user[0] != null) {
        debugPrint('Opening chat with user: ${user[0]['username']}');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UsersMessageScreen(
                    usersName: user[0]['username'],
                    isMultiConversation: user[0]['id'] >= 5000 ? true : false,
                    convID: user[0]['id'],
                    messageOnVoiceAssistant: null,
                  )),
        );
      } else {
        debugPrint('No valid user found for chat command');
      }
    } else if (command.contains('черный список') ||
        command.contains('блокировки') ||
        command.contains('blacklist') ||
        command.contains('black list')) {
      Navigator.pushNamed(context, '/black_list');
    } else {
      debugPrint('No matching command found: $command');
    }
    stopListening();
  }

  List<dynamic> _extractUserNameFromCommand(String command) {
    debugPrint('Extracting username from command: $command');
    if (friends.isEmpty) {
      debugPrint(
          'Error: Friends list is empty when trying to extract username');
      return [];
    }

    for (var friend in friends) {
      String username = friend['username'].toLowerCase();
      String commandLower = command.toLowerCase();
      if (command.contains(username)) {
        debugPrint('Found matching friend: ${friend['username']}');
        return [friend];
      }
      if (commandLower.contains(username)) {
        debugPrint(
            'Found matching friend (case insensitive): ${friend['username']}');
        return [friend];
      }
    }
    debugPrint('No matching friend found, returning first friend');
    return [];
  }
}
