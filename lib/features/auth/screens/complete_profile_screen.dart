import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/app_router.dart';
import '../../../core/widgets/dorm_dropdown.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCtrl = TextEditingController();
  String? _selectedDorm;

  @override
  void dispose() { _roomCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.updateDormInfo(dormName: _selectedDorm!, roomNumber: _roomCtrl.text.trim());
    if (context.mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 48),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('One more step! 🏠', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Tell us where you live', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
        ])),
        const SizedBox(height: 32),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dormitory Building', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DormDropdown(value: _selectedDorm, onChanged: (v) => setState(() => _selectedDorm = v)),
            const SizedBox(height: 16),
            const Text('Room Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roomCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Numbers only', prefixIcon: Icon(Icons.meeting_room_outlined, size: 20)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter room number' : null),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _save,
              child: auth.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text('Save & Continue')),
          ])),
        )),
      ])),
    );
  }
}