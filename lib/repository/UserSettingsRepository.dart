import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserSettingsRepository {
  final String _baseUrl = dotenv.get('BASEURL');

  Future<void> uploadPhoto(int userId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/users/$userId/photos'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode != 201) {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Photo upload error: $e');
    }
  }

  Future<Uint8List?> getLatestPhoto(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/photos/latest'),
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      throw Exception('Photo download error: $e');
    }
  }
}
