import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/network/authentication/user_authentication.dart';

class MarketService {
  final String _base = SecreteData.authUrl;

  Future<List<Map<String, dynamic>>> getAdverts() async {
    final url = Uri.parse('$_base${SecreteData.marketAdvertsEndpoint}');
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body);
    } else {
      throw Exception('Failed to load adverts');
    }
  }

  Future<List<Map<String, dynamic>>> getShops({String? search, int page = 1, int limit = 20}) async {
    String urlStr = '$_base${SecreteData.marketShopsEndpoint}?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) urlStr += '&search=$search';

    final url = Uri.parse(urlStr);
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['shops'] ?? []);
    } else {
      throw Exception('Failed to load shops');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts({String? search, int page = 1, int limit = 22}) async {
    String urlStr = '$_base${SecreteData.marketProductsEndpoint}?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) urlStr += '&search=$search';
    
    final url = Uri.parse(urlStr);
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['products'] ?? []);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 6}) async {
    final url = Uri.parse('$_base${SecreteData.marketTopProductsEndpoint}?limit=$limit');
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body);
    } else {
      throw Exception('Failed to load top products');
    }
  }

  Future<List<Map<String, dynamic>>> getServices({String? search, int page = 1, int limit = 20}) async {
    String urlStr = '$_base${SecreteData.marketServicesEndpoint}?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) urlStr += '&search=$search';
    
    final url = Uri.parse(urlStr);
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['services'] ?? []);
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> searchMarket(String query) async {
    final products = await getProducts(search: query, limit: 10);
    final services = await getServices(search: query, limit: 10);
    return {
      'products': products,
      'services': services,
    };
  }

  Future<void> rateProduct(String productId, double stars) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/market/products/$productId/rate');
    
    // We can use a generic rater key for now or fetch the current user id
    final response = await http.put(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "stars": stars,
        "rater": token.hashCode.toString(), // Simplified rater key
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rate product');
    }
  }

  Future<void> rateService(String serviceId, double stars) async {
    final token = await TokenStorage.loadToken();
    final url = Uri.parse('$_base/api/v1/market/services/$serviceId/rate');
    
    final response = await http.put(
      url,
      headers: SecreteData(token).getHeaders(),
      body: jsonEncode({
        "stars": stars,
        "rater": token.hashCode.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to rate service');
    }
  }

  Future<Map<String, dynamic>> getProduct(String productId) async {
    final url = Uri.parse('$_base${SecreteData.marketProductsEndpoint}/$productId');
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<Map<String, dynamic>> getShop(String shopId) async {
    final url = Uri.parse('$_base${SecreteData.marketShopsEndpoint}/$shopId');
    final response = await http.get(url, headers: const SecreteData().getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shop details');
    }
  }
}
