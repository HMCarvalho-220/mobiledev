// screens/product_detail_screen.dart
//
// TELA 2 — Detalhes do produto + ação de compra.
// Após a compra, recarrega o produto do backend para atualizar o estoque.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/order_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  int _quantity = 1;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  void _increment() {
    if (_quantity < _product.stock) setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _purchase() async {
    setState(() => _isPurchasing = true);

    try {
      final provider = context.read<OrderProvider>();
      final order = await provider.createOrder(_product.id, _quantity);

      // ── Atualiza o estoque buscando o produto atualizado do backend ────────
      // Isso resolve o problema do estoque não atualizar na tela após a compra.
      final updatedProduct = await ApiService(
        buyerId: provider.buyerId,
      ).fetchProduct(_product.id);

      if (mounted) {
        setState(() {
          _product = updatedProduct; // atualiza estoque na tela
          _quantity = 1;            // reseta quantidade
        });
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Color(0xFF0F6E56), size: 48),
          title: const Text('Pedido realizado!'),
          content: Text(
            'Pedido #${order.id} criado com sucesso.\n'
            'Total: R\$ ${order.totalPrice.toStringAsFixed(2)}\n\n'
            'Acompanhe o status na aba "Meus Pedidos".',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Ver meus pedidos'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar comprando'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _product.price * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 72, color: Color(0xFF534AB7)),
            ),
            const SizedBox(height: 16),

            Text(_product.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Vendido por ${_product.sellerName}',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),

            Text(
              'R\$ ${_product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56)),
            ),
            const SizedBox(height: 4),

            // Estoque — atualiza após a compra
            Row(
              children: [
                Icon(
                  _product.stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 16,
                  color: _product.stock > 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _product.stock > 0
                      ? '${_product.stock} unidades disponíveis'
                      : 'Produto esgotado',
                  style: TextStyle(
                    color: _product.stock > 0 ? Colors.grey[600] : Colors.red,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_product.description.isNotEmpty) ...[
              const Text('Descrição',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(_product.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 20),
            ],

            // Seletor de quantidade
            const Text('Quantidade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFF534AB7),
                  iconSize: 32,
                ),
                Text('$_quantity',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF534AB7),
                  iconSize: 32,
                ),
                const Spacer(),
                Text(
                  'Total: R\$ ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F6E56)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _product.isAvailable && !_isPurchasing ? _purchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF534AB7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _product.isAvailable ? 'Comprar agora' : 'Produto esgotado',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
