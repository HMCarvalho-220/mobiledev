// main.dart — App do Vendedor
//
// Ponto de entrada. Começa na tela de login.
// Após login, navegação com 2 abas:
//   - Pendentes (com notificação assíncrona)
//   - Em andamento

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/pending_orders_screen.dart';
import 'screens/active_orders_screen.dart';
import 'services/seller_provider.dart';

void main() {
  runApp(const MarketplaceSellerApp());
}

class MarketplaceSellerApp extends StatelessWidget {
  const MarketplaceSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerProvider(),
      child: MaterialApp(
        title: 'Marketplace — Vendedor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6E56)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PendingOrdersScreen(),   // Tela 1: pedidos pendentes + notificação
    ActiveOrdersScreen(),    // Tela 3: pedidos em andamento
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SellerProvider>();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              // Badge mostra contagem de pedidos pendentes
              isLabelVisible: provider.pendingOrders.isNotEmpty,
              label: Text('${provider.pendingOrders.length}'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: const Icon(Icons.inbox),
            label: 'Pendentes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Em andamento',
          ),
        ],
      ),
    );
  }
}
