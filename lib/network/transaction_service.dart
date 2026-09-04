import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';

class TransactionService {
  final String _base = SecreteData.authUrl;

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/transactions');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
