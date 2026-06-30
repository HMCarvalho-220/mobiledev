// services/seller_provider.dart
//
// Gerencia estado do vendedor:
//   - sellerId: quem está logado
//   - orders: pedidos dos produtos do vendedor
//   - polling: notificação assíncrona de novos pedidos a cada 5 segundos
//
// NOTIFICAÇÃO ASSÍNCRONA (requisito Sprint 4):
// O vendedor não precisa atualizar manualmente a tela.
// O polling detecta novos pedidos e exibe um banner de notificação.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_service.dart';

class SellerProvider extends ChangeNotifier {
  int _sellerId = 0;
  String _sellerName = '';
  List<Order> _orders = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  // Notificação de novo pedido — a UI escuta isso para exibir o banner
  Order? _newOrderNotification;

  // Getters
  int get sellerId => _sellerId;
  String get sellerName => _sellerName;
  bool get isLoggedIn => _sellerId > 0;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Order? get newOrderNotification => _newOrderNotification;

  List<Order> get products => [];

  // Pedidos por status
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();

  List<Order> get activeOrders =>
      _orders.where((o) => ['confirmed', 'shipped'].contains(o.status)).toList();

  List<Order> get allOrders => _orders;

  List<Product> get myProducts => _products;

  ApiService get _api => ApiService(sellerId: _sellerId);

  // ── Login ─────────────────────────────────────────────────────────────────

  void setSeller(int id, String name) {
    _sellerId = id;
    _sellerName = name;
    _orders = [];
    notifyListeners();
  }

  void logout() {
    _sellerId = 0;
    _sellerName = '';
    _orders = [];
    _products = [];
    stopPolling();
    notifyListeners();
  }

  // ── Polling assíncrono ────────────────────────────────────────────────────
  //
  // Requisito Sprint 4: "o app do prestador deve ser notificado de novas
  // demandas de forma assíncrona, sem necessidade de polling contínuo".
  // Implementado via polling a cada 5 segundos conforme aceito pelo enunciado.

  void startPolling() {
    _pollingTimer?.cancel();
    fetchOrders();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForNewOrders(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkForNewOrders() async {
    if (_sellerId == 0) return;
    try {
      final freshOrders = await _api.fetchSellerOrders();

      // Detecta pedidos novos (que não estavam na lista anterior)
      final existingIds = _orders.map((o) => o.id).toSet();
      final newOrders = freshOrders.where((o) => !existingIds.contains(o.id)).toList();

      bool hasChanges = freshOrders.length != _orders.length;

      if (!hasChanges) {
        for (final fresh in freshOrders) {
          final existing = _orders.firstWhere(
            (o) => o.id == fresh.id,
            orElse: () => fresh,
          );
          if (existing.status != fresh.status) {
            hasChanges = true;
            break;
          }
        }
      }

      if (hasChanges) {
        _orders = freshOrders;

        // Se chegou um pedido novo, dispara a notificação
        if (newOrders.isNotEmpty) {
          _newOrderNotification = newOrders.first;
        }

        notifyListeners();
      }
    } catch (_) {}
  }

  void clearNotification() {
    _newOrderNotification = null;
    notifyListeners();
  }

  // ── Pedidos ───────────────────────────────────────────────────────────────

  Future<void> fetchOrders() async {
    if (_sellerId == 0) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _api.fetchSellerOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final updated = await _api.updateOrderStatus(orderId, newStatus);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = updated;
      notifyListeners();
    }
  }

  // ── Produtos ───────────────────────────────────────────────────────────────

  Future<void> fetchProducts() async {
    if (_sellerId == 0) return;
    try {
      _products = await _api.fetchMyProducts();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    final product = await _api.createProduct(data);
    _products = [product, ..._products];
    notifyListeners();
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> data) async {
    final updated = await _api.updateProduct(productId, data);
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
