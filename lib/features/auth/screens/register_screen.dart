import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/app_router.dart';
import '../../../core/widgets/dorm_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  String? _selectedDorm;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _roomCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _emailCtrl.text.trim(), password: _pwCtrl.text,
      name: _nameCtrl.text.trim(), roomNumber: _roomCtrl.text.trim(),
      dormName: _selectedDorm!);
    if (!mounted) return;
    if (ok) context.go(RouteNames.home);
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(auth.errorMessage ?? 'Registration failed'),
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
        const SizedBox(height: 32),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => context.pop(), child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
          const SizedBox(height: 20),
          const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 6),
          Text('Join DormFix', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
        ])),
        const SizedBox(height: 32),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: SingleChildScrollView(child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Full Name'),
            const SizedBox(height: 8),
            TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded, size: 20)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null),
            const SizedBox(height: 16),
            _label('Dormitory Building'),
            const SizedBox(height: 8),
            DormDropdown(value: _selectedDorm, onChanged: (v) => setState(() => _selectedDorm = v)),
            const SizedBox(height: 16),
            _label('Room Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roomCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(prefixIcon: Icon(Icons.meeting_room_outlined, size: 20)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter room number' : null),
            const SizedBox(height: 16),
            _label('Email'),
            const SizedBox(height: 8),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded, size: 20)),
              validator: (v) => v == null || v.isEmpty ? 'Please enter your email' : null),
            const SizedBox(height: 16),
            _label('Password'),
            const SizedBox(height: 8),
            TextFormField(controller: _pwCtrl, obscureText: _obscure,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure))),
              validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: auth.isLoading ? null : _register,
              child: auth.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Create Account')),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ', style: TextStyle(fontSize: 14, color: Color(0xFF80868B))),
              GestureDetector(onTap: () => context.pop(),
                child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A73E8)))),
            ]),
          ]))),
        )),
      ])),
    );
  }
  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF202124)));
}
