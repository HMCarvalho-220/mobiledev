// screens/pending_orders_screen.dart
//
// TELA 1 — Lista de pedidos pendentes do vendedor.
// Exigida pela Sprint 4: "lista de solicitações pendentes".
//
// NOTIFICAÇÃO ASSÍNCRONA:
// Quando o polling detecta um pedido novo, exibe um banner verde
// no topo da tela sem o vendedor precisar fazer nada.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/seller_provider.dart';
import 'order_detail_screen.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    context.read<SellerProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pedidos Pendentes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
        actions: [
          // Ícone de sync indica que o polling está ativo
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Verificando novos pedidos a cada 5s',
              child: Icon(Icons.sync, color: Colors.white.withOpacity(0.8), size: 20),
            ),
          ),
        ],
      ),
      body: Consumer<SellerProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Banner de notificação assíncrona
              // Aparece automaticamente quando chega um pedido novo via polling
              if (provider.newOrderNotification != null)
                _NewOrderBanner(
                  order: provider.newOrderNotification!,
                  onDismiss: () => provider.clearNotification(),
                ),

              // Lista de pedidos pendentes
              Expanded(child: _buildBody(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(SellerProvider provider) {
    if (provider.isLoading && provider.pendingOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.pendingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Nenhum pedido pendente.',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('Novos pedidos aparecerão aqui automaticamente.',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.pendingOrders.length,
        itemBuilder: (context, index) {
          return _OrderCard(order: provider.pendingOrders[index]);
        },
      ),
    );
  }
}

// ── Banner de notificação de novo pedido ──────────────────────────────────────

class _NewOrderBanner extends StatelessWidget {
  final Order order;
  final VoidCallback onDismiss;

  const _NewOrderBanner({required this.order, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F6E56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '🔔 Novo pedido #${order.id} — ${order.productTitle}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Card de pedido pendente ───────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text('Pendente',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
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
                  Text('Comprador: ${order.buyerName ?? "ID ${order.buyerId}"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('R\$ ${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F6E56))),
                ],
              ),
              const SizedBox(height: 4),
              Text('${order.quantity} unidade(s)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }
}
