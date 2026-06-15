// screens/product_list_screen.dart
//
// TELA 1 — Listagem de produtos disponíveis.
// Usa o buyerId do OrderProvider para criar o ApiService correto.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/order_provider.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final buyerId = context.read<OrderProvider>().buyerId;
      final products = await ApiService(buyerId: buyerId).fetchProducts();
      setState(() => _products = products);
    } catch (e) {
      setState(() => _error = 'Não foi possível carregar os produtos.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF534AB7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadProducts, child: const Text('Tentar novamente')),
        ],
      ));
    }

    if (_products.isEmpty) {
      return const Center(child: Text('Nenhum produto disponível no momento.'));
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        itemBuilder: (context, index) => _ProductCard(product: _products[index]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

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
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF534AB7), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Vendido por ${product.sellerName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('R\$ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold, color: Color(0xFF0F6E56))),
                        _StockBadge(stock: product.stock),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final isLow = stock <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLow ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLow ? Colors.orange : Colors.green),
      ),
      child: Text('$stock em estoque',
          style: TextStyle(fontSize: 11,
              color: isLow ? Colors.orange[800] : Colors.green[800],
              fontWeight: FontWeight.w500)),
    );
  }
}
