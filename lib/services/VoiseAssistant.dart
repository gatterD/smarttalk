import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smarttalk/features/SearchScreen/view/SearchScreen.dart';
import 'package:smarttalk/features/BlackListScreen/view/BlackListScreen.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class VoiceAssistant {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

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
            onTextRecognized(command); // <- уведомляем внешний код
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
    } else if (command.contains('черный список') ||
        command.contains('блокировки')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BlackListScreen()),
      );
    }
    stopListening();
  }
}
