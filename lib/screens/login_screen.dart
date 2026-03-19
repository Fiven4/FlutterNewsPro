import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ошибка входа. Проверьте данные.'),
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: authController,
          builder: (context, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.layers_rounded, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Добро пожаловать',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Войдите, чтобы продолжить чтение',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(_emailController, 'Электронная почта', Icons.alternate_email_rounded),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, 'Пароль', Icons.lock_outline_rounded, obscure: true),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: authController.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: const Color(0xFF0F172A).withOpacity(0.5),
                      ),
                      child: authController.isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Войти', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Создать новый аккаунт', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: const Color(0xFF94A3B8)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }
}