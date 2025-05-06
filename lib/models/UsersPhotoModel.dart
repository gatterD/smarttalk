import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UsersPhotoModel {
  final String _baseUrl = dotenv.get('BASEURL');

  Future<List<dynamic>> enrichUsersWithPhotos(List<dynamic> users) async {
    List<dynamic> enrichedUsers = [];

    for (var user in users) {
      try {
        Uint8List? photo = await getLatestPhoto(user['id']);

        var enrichedUser = Map<String, dynamic>.from(user);

        enrichedUser['user_photo'] = photo;

        enrichedUsers.add(enrichedUser);
      } catch (e) {
        print('Error loading photo for user ${user['id']}: $e');
        enrichedUsers.add(user);
      }
    }

    return enrichedUsers;
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
