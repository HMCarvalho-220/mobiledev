// screens/order_detail_screen.dart
//
// TELA 2 — Detalhes do pedido com opção de aceitar/recusar.
// Exigida pela Sprint 4: "detalhes da solicitação com opção de aceitar/recusar".
//
// Após aceitar/recusar, o backend publica order.status_updated no RabbitMQ,
// que o app do comprador recebe via polling.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/seller_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      await context.read<SellerProvider>().updateOrderStatus(_order.id, newStatus);

      if (!mounted) return;

      final labels = {
        'confirmed': 'confirmado',
        'shipped':   'marcado como despachado',
        'delivered': 'marcado como entregue',
        'cancelled': 'cancelado',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido #${_order.id} ${labels[newStatus]}!'),
          backgroundColor: newStatus == 'cancelled' ? Colors.red : const Color(0xFF0F6E56),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return const Color(0xFF534AB7);
      case 'shipped':   return Colors.blue;
      case 'delivered': return const Color(0xFF0F6E56);
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(_order.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Pedido #${_order.id}'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de informações do pedido
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Informações do Pedido',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.5)),
                          ),
                          child: Text(_order.statusLabel,
                              style: TextStyle(color: color, fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _InfoRow(label: 'Produto', value: _order.productTitle),
                    _InfoRow(label: 'Quantidade', value: '${_order.quantity} unidade(s)'),
                    _InfoRow(label: 'Preço unitário',
                        value: 'R\$ ${_order.unitPrice.toStringAsFixed(2)}'),
                    _InfoRow(label: 'Total',
                        value: 'R\$ ${_order.totalPrice.toStringAsFixed(2)}',
                        bold: true),
                    const Divider(height: 20),
                    _InfoRow(label: 'Comprador',
                        value: _order.buyerName ?? 'ID ${_order.buyerId}'),
                    _InfoRow(label: 'Data do pedido',
                        value: '${_order.createdAt.day.toString().padLeft(2,'0')}/'
                               '${_order.createdAt.month.toString().padLeft(2,'0')}/'
                               '${_order.createdAt.year} '
                               '${_order.createdAt.hour.toString().padLeft(2,'0')}:'
                               '${_order.createdAt.minute.toString().padLeft(2,'0')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de ações
            if (_order.nextStatuses.isNotEmpty) ...[
              const Text('Ações disponíveis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ..._order.nextStatuses.map((status) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : () => _updateStatus(status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'cancelled'
                          ? Colors.red
                          : const Color(0xFF0F6E56),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(_order.labelFor(status),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              )),
            ] else
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Text('Este pedido está em estado final: ${_order.statusLabel}.',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),

            // Aviso sobre notificação assíncrona
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFE1F5EE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: Color(0xFF0F6E56), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ao atualizar o status, o comprador será notificado automaticamente via RabbitMQ.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF0F6E56)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
