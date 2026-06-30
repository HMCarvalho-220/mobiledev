// services/api_service.dart
//
// Todas as chamadas HTTP ao backend Flask para o app do vendedor.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api/v1';

  final int sellerId;
  const ApiService({required this.sellerId});

  // ── Usuários ───────────────────────────────────────────────────────────────

  /// Valida login do vendedor pelo email.
  /// GET /api/v1/users/:id
  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['data']) as Map<String, dynamic>;
    }
    throw Exception('Usuário não encontrado');
  }

  /// Busca usuário por email para login.
  /// GET /api/v1/users
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      try {
        return data.firstWhere(
          (u) => u['email'] == email,
        ) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    throw Exception('Erro ao buscar usuários');
  }

  // ── Pedidos ────────────────────────────────────────────────────────────────

  /// Busca todos os pedidos dos produtos do vendedor.
  /// GET /api/v1/orders
  /// Filtra no cliente pelos produtos do vendedor.
  Future<List<Order>> fetchSellerOrders() async {
    // Busca todos os produtos do vendedor
    final myProducts = await fetchMyProducts();
    final myProductIds = myProducts.map((p) => p.id).toSet();

    // Busca todos os pedidos e filtra pelos produtos do vendedor
    final response = await http.get(Uri.parse('$_baseUrl/orders'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data
          .map((json) => Order.fromJson(json))
          .where((o) => myProductIds.contains(o.productId))
          .toList();
    }
    throw Exception('Erro ao buscar pedidos');
  }

  /// Atualiza o status de um pedido.
  /// PATCH /api/v1/orders/:id/status
  Future<Order> updateOrderStatus(int orderId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body)['data']);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Erro ao atualizar status');
  }

  // ── Produtos ───────────────────────────────────────────────────────────────

  /// Busca produtos do vendedor logado.
  /// GET /api/v1/products?seller_id=X
  Future<List<Product>> fetchMyProducts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?seller_id=$sellerId'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Erro ao buscar produtos');
  }

  /// Cria um novo produto.
  /// POST /api/v1/products
  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'seller_id': sellerId}),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body)['data']);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Erro ao criar produto');
  }

  /// Atualiza um produto.
  /// PATCH /api/v1/products/:id
  Future<Product> updateProduct(int productId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/products/$productId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body)['data']);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Erro ao atualizar produto');
  }
}
