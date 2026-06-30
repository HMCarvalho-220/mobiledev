// screens/active_orders_screen.dart
//
// TELA 3 — Acompanhamento dos pedidos em andamento (confirmed, shipped).
// Exigida pela Sprint 4: "acompanhamento das solicitações em andamento".

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/seller_provider.dart';
import 'order_detail_screen.dart';

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Em Andamento',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: Consumer<SellerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.activeOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activeOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('Nenhum pedido em andamento.',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.activeOrders.length,
              itemBuilder: (context, index) {
                return _ActiveOrderCard(order: provider.activeOrders[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final Order order;
  const _ActiveOrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'confirmed': return const Color(0xFF534AB7);
      case 'shipped':   return Colors.blue;
      default:          return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case 'confirmed': return Icons.check_circle_outline;
      case 'shipped':   return Icons.local_shipping_outlined;
      default:          return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pedido #${order.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 14, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(order.statusLabel,
                            style: TextStyle(
                                color: _statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text(order.productTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.quantity} unidade(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('R\$ ${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F6E56))),
                ],
              ),
              const SizedBox(height: 8),
              // Barra de progresso do status
              _StatusProgressBar(status: order.status),
            ],
          ),
        ),
      ),
    );
  }
}

// Barra visual de progresso do pedido
class _StatusProgressBar extends StatelessWidget {
  final String status;
  const _StatusProgressBar({required this.status});

  int get _step {
    switch (status) {
      case 'confirmed': return 1;
      case 'shipped':   return 2;
      case 'delivered': return 3;
      default:          return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Confirmado', 'Despachado', 'Entregue'];
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i < _step;
        final current = i == _step - 1;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                color: done || current
                    ? const Color(0xFF0F6E56)
                    : Colors.grey[300],
              ),
              const SizedBox(height: 4),
              Text(steps[i],
                  style: TextStyle(
                      fontSize: 9,
                      color: done || current
                          ? const Color(0xFF0F6E56)
                          : Colors.grey[400],
                      fontWeight: current
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ],
          ),
        );
      }),
    );
  }
}
