// main.dart
//
// Ponto de entrada do app.
// Começa na LoginScreen — o comprador informa seu ID.
// Após login, vai para a navegação principal com as 3 telas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/my_orders_screen.dart';
import 'services/order_provider.dart';

void main() {
  runApp(const MarketplaceBuyerApp());
}

class MarketplaceBuyerApp extends StatelessWidget {
  const MarketplaceBuyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: MaterialApp(
        title: 'Marketplace — Comprador',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF534AB7)),
          useMaterial3: true,
        ),
        // Começa na tela de login
        home: const LoginScreen(),
      ),
    );
  }
}

// ── Navegação principal (após login) ─────────────────────────────────────────

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductListScreen(),  // Tela 1: listagem de produtos
    MyOrdersScreen(),     // Tela 2: meus pedidos com polling
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Produtos',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Meus Pedidos',
          ),
        ],
      ),
      // Botão de logout no app bar de cada tela fica aqui
    );
  }
}
