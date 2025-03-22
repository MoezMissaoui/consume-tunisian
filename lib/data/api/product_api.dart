import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';

class ProductApi {
  static const baseUrl = 'https://world.openfoodfacts.org/api/v2';

  static Future<Product?> getProduct(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 1) {
          return Product.fromJson(json);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }
}
