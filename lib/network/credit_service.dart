import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:first_flutter_project/global/credit_global.dart';

class CreditService {
  final String _base = SecreteData.authUrl;

  Future<List<CreditUser>> getCreditEntries() async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.creditEntriesEndpoint}');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => CreditUser(
        id: item['id'].hashCode, // Backend might use String ID, Flutter CreditUser uses int id
        name: item['customer_name'],
        amount: item['balance'],
        dueDate: item['due_date'] ?? '',
        status: _parseStatus(item['status']),
      )).toList();
    } else {
      throw Exception('Failed to load credit entries');
    }
  }

  Future<void> createCreditEntry(String customerName, double amount, String dueDate) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.creditEntriesEndpoint}');

    final response = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "customer_name": customerName,
        "amount": amount,
        "balance": amount,
        "due_date": dueDate,
        "status": "pending",
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create credit entry: ${response.body}');
    }
  }

  CreditStatus _parseStatus(String status) {
    switch (status) {
      case 'paid': return CreditStatus.paid;
      case 'overdue': return CreditStatus.overdue;
      default: return CreditStatus.pending;
    }
  }
}
