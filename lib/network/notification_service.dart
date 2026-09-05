import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';

class NotificationService {
  final String _base = SecreteData.authUrl;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.notificationsEndpoint}');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final token = await TokenStorage.loadToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final url = Uri.parse(
      '$_base${SecreteData.notificationsEndpoint}/$notificationId',
    );

    final response = await http.delete(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  Future<void> clearNotifications() async {
    final token = await TokenStorage.loadToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final url = Uri.parse('$_base${SecreteData.notificationsEndpoint}');

    final response = await http.delete(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear notifications');
    }
  }
}
