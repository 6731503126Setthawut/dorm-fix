import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email: _emailCtrl.text.trim(), password: _pwCtrl.text);
    if (!mounted) return;
    if (ok) context.go(RouteNames.home);
    else _showError(auth.errorMessage ?? 'Login failed');
  }

  Future<void> _googleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (ok) context.go(RouteNames.home);
    else if (auth.errorMessage != null) _showError(auth.errorMessage!);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFEA4335),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 48),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 52, height: 52,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 28)))),
          const SizedBox(height: 20),
          const Text('DormFix', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 6),
          Text('Report dorm issues, fast & easy.', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
        ])),
        const SizedBox(height: 40),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: SingleChildScrollView(child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sign In', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF202124), letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Welcome back!', style: TextStyle(fontSize: 14, color: Color(0xFF80868B))),
            const SizedBox(height: 28),
            // Google Button
            OutlinedButton(
              onPressed: auth.isLoading ? null : _googleLogin,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Color(0xFFDADCE0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.network('https://www.google.com/favicon.ico', width: 20, height: 20),
                const SizedBox(width: 10),
                const Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF202124))),
              ])),
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Divider(color: Color(0xFFDADCE0))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
              const Expanded(child: Divider(color: Color(0xFFDADCE0))),
            ]),
            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'student@dorm.ac.th', prefixIcon: Icon(Icons.mail_outline_rounded, size: 20)),
              validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : null),
            const SizedBox(height: 16),
            const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pwCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscure = !_obscure))),
              validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _login,
              child: auth.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Sign In')),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? ", style: TextStyle(fontSize: 14, color: Color(0xFF80868B))),
              GestureDetector(
                onTap: () => context.push(RouteNames.register),
                child: const Text('Register', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A73E8)))),
            ]),
          ]))))),
      ])),
    );
  }
}
