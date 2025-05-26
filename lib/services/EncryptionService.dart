import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  late final Encrypter _encrypter;
  static const _fixedIV = '16_BYTE_IV_12345'; // ровно 16 символов!

  factory EncryptionService() => _instance;

  EncryptionService._internal() {
    final key = _processKey(dotenv.env['ENCRYPTION_KEY']!);
    _encrypter = Encrypter(AES(key));
  }

  Key _processKey(String rawKey) {
    if (rawKey.length < 32) {
      rawKey = rawKey.padRight(32, '0');
    } else if (rawKey.length > 32) {
      rawKey = rawKey.substring(0, 32);
    }
    return Key.fromUtf8(rawKey);
  }

  String encrypt(String plainText) {
    try {
      final iv = IV.fromUtf8(_fixedIV); // IV ровно 16 байт
      return _encrypter.encrypt(plainText, iv: iv).base64;
    } catch (e) {
      throw Exception('Ошибка шифрования: $e');
    }
  }

  String decrypt(String encryptedText) {
    try {
      final iv = IV.fromUtf8(_fixedIV);
      return _encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      throw Exception('Ошибка дешифрования: $e');
    }
  }
}
