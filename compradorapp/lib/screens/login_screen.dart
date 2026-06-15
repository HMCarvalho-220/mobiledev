// screens/login_screen.dart
//
// Tela de entrada — comprador informa seu ID.
// Valida no backend se o ID existe e é um buyer antes de entrar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/order_provider.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _entrar() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() => _error = 'Informe seu ID de comprador.');
      return;
    }

    final id = int.tryParse(text);
    if (id == null || id <= 0) {
      setState(() => _error = 'ID inválido. Digite apenas números.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      // Valida se o usuário existe e é buyer
      final api = ApiService(buyerId: id);
      final user = await api.fetchUser(id);

      if (user['role'] != 'buyer') {
        setState(() => _error = 'Este ID não pertence a um comprador.');
        return;
      }

      if (!mounted) return;

      // Salva o ID no provider — agora todos os serviços usam este ID
      context.read<OrderProvider>().setBuyerId(id);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      setState(() => _error = 'Comprador não encontrado. Verifique o ID.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF534AB7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.storefront, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Marketplace',
                  style: TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const Text('App do Comprador',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 40),

              // Card de login
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20, offset: const Offset(0, 8),
                  )],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entrar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Informe seu ID de comprador para continuar.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ID do Comprador',
                        hintText: 'Ex: 2',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _entrar(),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _entrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF534AB7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Entrar',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
