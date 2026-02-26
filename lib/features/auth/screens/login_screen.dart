import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/app_router.dart';

class LoginScreen extends StatelessWidget {

  const LoginScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: SafeArea(child: Column(children: [
        const Spacer(),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 40)))),
          const SizedBox(height: 24),
          const Text('DormFix', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Report dorm issues, fast & easy.', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
        ])),
        const Spacer(),
        Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 48), child: Column(children: [
          OutlinedButton(
            onPressed: auth.isLoading ? null : () async {
              final ok = await context.read<AuthProvider>().signInWithGoogle();
              if (!context.mounted) return;
              if (!ok && context.read<AuthProvider>().errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.read<AuthProvider>().errorMessage!),
                  backgroundColor: const Color(0xFFEA4335),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16)));
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: auth.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF1A73E8)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: const Color(0xFF1A73E8), borderRadius: BorderRadius.circular(4)),
                    child: const Center(child: Text('G', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)))),
                  const SizedBox(width: 12),
                  const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF202124))),
                ])),
          const SizedBox(height: 16),
          Text('By continuing, you agree to our Terms of Service', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        ])),
      ])),
    );
  }
}
