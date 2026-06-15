// screens/my_orders_screen.dart
//
// TELA 3 — Lista de pedidos do comprador com atualização assíncrona.
// Exigida pela Sprint 3: "atualização assíncrona de estado".
//
// O que faz:
//   - Lista todos os pedidos do comprador
//   - Inicia o polling ao entrar na tela (verifica backend a cada 5 segundos)
//   - Se o vendedor atualizar o status, a tela atualiza automaticamente
//   - Para o polling ao sair da tela (economia de recursos)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia o polling assim que a tela abre
    // O provider buscará os pedidos imediatamente e depois a cada 5s
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    // Para o polling quando o usuário sai da tela
    context.read<OrderProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Meus Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
        actions: [
          // Indicador visual de que o polling está ativo
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Atualizando a cada 5 segundos',
              child: Icon(
                Icons.sync,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      // Consumer escuta o OrderProvider e reconstrói quando notifyListeners() é chamado
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text('Não foi possível carregar os pedidos.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.fetchOrders(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Você ainda não fez nenhum pedido.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: provider.orders[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Card de pedido ────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  // Cor do status para feedback visual ao comprador
  Color _statusColor() {
    switch (order.status) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return const Color(0xFF534AB7);
      case 'shipped':   return Colors.blue;
      case 'delivered': return const Color(0xFF0F6E56);
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  IconData _statusIcon() {
    switch (order.status) {
      case 'pending':   return Icons.hourglass_empty;
      case 'confirmed': return Icons.check_circle_outline;
      case 'shipped':   return Icons.local_shipping_outlined;
      case 'delivered': return Icons.done_all;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: número do pedido e status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        order.statusLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Detalhes do pedido
            Text(
              order.productTitle,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.quantity}x R\$ ${order.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  'Total: R\$ ${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F6E56),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
