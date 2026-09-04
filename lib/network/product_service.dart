import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class ProductService {
  final String _base = SecreteData.authUrl;

  Future<List<Product>> getProducts() async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.productsEndpoint}');

    final response = await http.get(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> createProduct(Product product) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.productsEndpoint}');

    final response = await http.post(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "name": product.name,
        "sku": product.sku,
        "price": product.price,
        "stock": product.quantity,
        "category": product.category,
      }),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<Product> updateProduct(String productId, Map<String, dynamic> updates) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.productsEndpoint}/$productId');

    final response = await http.patch(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base${SecreteData.productsEndpoint}/$productId');

    final response = await http.delete(
      url,
      headers: SecreteData(token).getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }
}
