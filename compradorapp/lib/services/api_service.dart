// services/api_service.dart
//
// Responsável por TODA comunicação HTTP com o backend Flask.
// buyerId agora é dinâmico — vem da tela de login.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api/v1';

  // buyerId agora é passado pelo construtor — não é mais fixo
  final int buyerId;
  const ApiService({required this.buyerId});

  // ── Usuários ───────────────────────────────────────────────────────────────

  /// Busca um usuário pelo ID para validar o login.
  /// Corresponde ao endpoint: GET /api/v1/users/:id
  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception('Usuário não encontrado');
  }

  // ── Produtos ───────────────────────────────────────────────────────────────

  /// Busca todos os produtos ativos no marketplace.
  /// Corresponde ao endpoint: GET /api/v1/products
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Erro ao buscar produtos: ${response.statusCode}');
  }

  // ── Pedidos ────────────────────────────────────────────────────────────────

  /// Cria um novo pedido.
  /// Corresponde ao endpoint: POST /api/v1/orders
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

  /// Busca APENAS os pedidos do comprador logado.
  /// Corresponde ao endpoint: GET /api/v1/orders?buyer_id=X
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

  /// Busca um produto por ID — usado para atualizar estoque após compra.
  /// Corresponde ao endpoint: GET /api/v1/products/:id
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
