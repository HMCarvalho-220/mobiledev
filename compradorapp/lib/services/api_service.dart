

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api/v1';


  final int buyerId;
  const ApiService({required this.buyerId});


  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception('Usuário não encontrado');
  }


  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Erro ao buscar produtos: ${response.statusCode}');
  }


  Future<Order> createOrder(int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyer_id':   buyerId,
        'product_id': productId,
        'quantity':   quantity,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return Order.fromJson(body['data']);
    }

    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Erro ao criar pedido');
  }


  Future<List<Order>> fetchMyOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders?buyer_id=$buyerId'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => Order.fromJson(json)).toList();
    }

    throw Exception('Erro ao buscar pedidos: ${response.statusCode}');
  }

  Future<Product> fetchProduct(int productId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$productId'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['data']);
    }

    throw Exception('Produto não encontrado');
  }
}
