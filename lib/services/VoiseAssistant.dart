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
  List<dynamic> friends = []; // Добавляем список друзей
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
      onStatus: (val) => print('Status: $val'),
      onError: (val) => print('Error: $val'),
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
    if (command.contains('поиск') || command.contains('найти')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
      );
    } else if (command.contains('создать чат') ||
        command.contains('новый чат')) {
      Navigator.pushNamed(context, '/chat-creation');
    } else if (command.contains('настройки')) {
      Navigator.pushNamed(context, '/settings');
    } else if (command.contains('напиши') || command.contains('отправь')) {
      final originalCommand = command;
      final lowerCommand = command.toLowerCase();

      List<dynamic> user = _extractUserNameFromCommand(lowerCommand);

      if (user.isNotEmpty && user[0] != null) {
        String username = user[0]['username'].toLowerCase();

        int usernameIndex = lowerCommand.indexOf(username);

        if (usernameIndex != -1) {
          String message =
              originalCommand.substring(usernameIndex + username.length).trim();

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
      }
    } else if (command.contains('чат') || command.contains('открой чат')) {
      List<dynamic> user = _extractUserNameFromCommand(command);
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
    } else if (command.contains('черный список') ||
        command.contains('блокировки')) {
      Navigator.pushNamed(context, '/black_list');
    }
    stopListening();
  }

  List<dynamic> _extractUserNameFromCommand(String command) {
    for (var friend in friends) {
      String username = friend['username'].toLowerCase();
      if (command.contains(username)) {
        return friend;
      }
    }
    return friends[0];
  }
}
