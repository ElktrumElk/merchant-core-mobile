import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:first_flutter_project/pages/pos/cart_panel.dart';

class PosService {
  final String _base = SecreteData.authUrl;

  Future<void> checkout(List<CartItem> items, double total, String paymentMethod) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.checkoutEndpoint}');

    final response = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "items": items.map((item) => {
          "id": item.product.id,
          "name": item.product.name,
          "quantity": item.quantity,
          "price": item.product.price,
        }).toList(),
        "total": total,
        "payment_method": paymentMethod,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Checkout failed: ${response.body}');
    }
  }
}
