// screens/login_screen.dart
//
// Tela de login do vendedor pelo ID.
// Simples e funcional — valida se o ID existe e é um seller.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/seller_provider.dart';
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
      setState(() => _error = 'Informe seu ID de vendedor.');
      return;
    }

    final id = int.tryParse(text);
    if (id == null || id <= 0) {
      setState(() => _error = 'ID inválido.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final api = ApiService(sellerId: id);
      final user = await api.fetchUser(id);

      if (user['role'] != 'seller') {
        setState(() => _error = 'Este ID não é de um vendedor.');
        return;
      }

      if (!mounted) return;

      context.read<SellerProvider>().setSeller(id, user['name'] as String);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      setState(() => _error = 'Vendedor não encontrado. Verifique o ID.');
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
      backgroundColor: const Color(0xFF0F6E56),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.store, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Marketplace',
                  style: TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const Text('App do Vendedor',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 40),

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
                    const Text('Entrar como Vendedor',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Informe seu ID de vendedor.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ID do Vendedor',
                        hintText: 'Ex: 1',
                        prefixIcon: const Icon(Icons.store_outlined),
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
                          backgroundColor: const Color(0xFF0F6E56),
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
