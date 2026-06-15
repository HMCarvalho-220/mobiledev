// services/order_provider.dart
//
// Gerencia o estado global do app:
//   - buyerId: quem está logado
//   - orders: pedidos do comprador
//   - polling: atualização assíncrona a cada 5 segundos

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'api_service.dart';

class OrderProvider extends ChangeNotifier {
  int _buyerId = 0;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  // Getters
  int get buyerId => _buyerId;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _buyerId > 0;

  // ApiService criado sob demanda com o buyerId correto
  ApiService get _api => ApiService(buyerId: _buyerId);

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Chamado pela LoginScreen após validar o usuário no backend.
  void setBuyerId(int id) {
    _buyerId = id;
    _orders = [];
    notifyListeners();
  }

  void logout() {
    _buyerId = 0;
    _orders = [];
    stopPolling();
    notifyListeners();
  }

  // ── Polling assíncrono ────────────────────────────────────────────────────

  void startPolling() {
    _pollingTimer?.cancel();
    fetchOrders();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkForUpdates(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkForUpdates() async {
    if (_buyerId == 0) return;
    try {
      final freshOrders = await _api.fetchMyOrders();
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
        notifyListeners();
      }
    } catch (_) {}
  }

  // ── Pedidos ───────────────────────────────────────────────────────────────

  Future<void> fetchOrders() async {
    if (_buyerId == 0) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _api.fetchMyOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria pedido E recarrega o produto para atualizar estoque na tela.
  Future<Order> createOrder(int productId, int quantity) async {
    final order = await _api.createOrder(productId, quantity);
    _orders = [order, ..._orders];
    notifyListeners();
    return order;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
