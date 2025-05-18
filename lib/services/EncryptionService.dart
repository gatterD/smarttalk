import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  late final Encrypter _encrypter;
  late final IV _iv;

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal() {
    final keyString = dotenv.env['ENCRYPTION_KEY']!;
    if (keyString.length != 32) {
      throw Exception('Encryption key must be 32 characters long');
    }

    final key = Key.fromUtf8(keyString);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromLength(16);
  }

  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
