import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  RequestCategory _cat = RequestCategory.other;
  List<Uint8List> _imageBytes = [];
  bool _submitting = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _roomCtrl.text = context.read<AuthProvider>().userModel?.roomNumber ?? '';
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _roomCtrl.dispose(); super.dispose(); }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    for (final x in picked) {
      final bytes = await x.readAsBytes();
      setState(() => _imageBytes.add(bytes));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes.add(bytes));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    try {
      await context.read<RequestProvider>().addRequest(
        userId: auth.firebaseUser!.uid,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _cat,
        roomNumber: _roomCtrl.text.trim(),
        imageBytes: _imageBytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text('Request submitted!', style: TextStyle(fontWeight: FontWeight.w600))]),
        backgroundColor: const Color(0xFF34A853), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16)));
      context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEA4335)));
    } finally { if (mounted) setState(() => _submitting = false); }
  }

  void _showImageOptions() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDADCE0), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Add Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () { Navigator.pop(context); _takePhoto(); },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1A73E8).withOpacity(0.2))),
              child: const Column(children: [Icon(Icons.camera_alt_rounded, size: 32, color: Color(0xFF1A73E8)), SizedBox(height: 8), Text('Camera', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A73E8)))])))),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(onTap: () { Navigator.pop(context); _pickFromGallery(); },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: const Color(0xFF34A853).withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF34A853).withOpacity(0.2))),
              child: const Column(children: [Icon(Icons.photo_library_rounded, size: 32, color: Color(0xFF34A853)), SizedBox(height: 8), Text('Gallery', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF34A853)))])))),
        ]),
        const SizedBox(height: 8),
      ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('New Request'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop())),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        _sec('Category', GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3,
          children: RequestCategory.values.map((c) { final sel = _cat == c; return GestureDetector(onTap: () => setState(() => _cat = c), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(color: sel ? const Color(0xFF1A73E8).withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? const Color(0xFF1A73E8) : const Color(0xFFDADCE0), width: sel ? 2 : 1)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.icon, style: const TextStyle(fontSize: 22)), const SizedBox(height: 4), Text(c.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? const Color(0xFF1A73E8) : const Color(0xFF80868B)))]))); }).toList())),
        const SizedBox(height: 20),
        _sec('Room Number', TextFormField(controller: _roomCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 301', prefixIcon: Icon(Icons.meeting_room_outlined, size: 20)),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null)),
        const SizedBox(height: 20),
        _sec('Issue Title', TextFormField(controller: _titleCtrl, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Air conditioner not working', prefixIcon: Icon(Icons.title_rounded, size: 20)),
          validator: (v) => v == null || v.trim().length < 5 ? 'Title too short (min 5 chars)' : null)),
        const SizedBox(height: 20),
        _sec('Description', TextFormField(controller: _descCtrl, maxLines: 5, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Describe the issue in detail...'),
          validator: (v) => v == null || v.trim().length <10 ? 'Please provide more detail (min 10 chars)' : null)),
        const SizedBox(height: 20),
        _sec('Photos (Optional)', Column(children: [
          if (_imageBytes.isNotEmpty) ...[
            SizedBox(height: 110, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _imageBytes.length + 1, separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == _imageBytes.length) return GestureDetector(onTap: _showImageOptions,
                  child: Container(width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0), style: BorderStyle.solid)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_rounded, color: Color(0xFF1A73E8), size: 28), Text('Add', style: TextStyle(fontSize: 12, color: Color(0xFF1A73E8), fontWeight: FontWeight.w600))])));
                return Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_imageBytes[i], width: 100, height: 100, fit: BoxFit.cover)),
                  Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _imageBytes.removeAt(i)),
                    child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Color(0xFFEA4335), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 12)))),
                ]);
              })),
            const SizedBox(height: 10),
          ] else
            GestureDetector(onTap: _showImageOptions, child: Container(height: 80,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADCE0))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_outlined, size: 24, color: Color(0xFF1A73E8)),
                SizedBox(width: 10),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Add Photos', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A73E8), fontSize: 15)),
                  Text('Camera or Gallery', style: TextStyle(fontSize: 12, color: Color(0xFF80868B)))])]))),
        ])),
        const SizedBox(height: 32),
        if (_submitting)
          const Center(child: Column(children: [CircularProgressIndicator(color: Color(0xFF1A73E8)), SizedBox(height: 12), Text('Uploading...', style: TextStyle(color: Color(0xFF80868B), fontWeight: FontWeight.w600))]))
        else
          ElevatedButton(onPressed: _submit, child: const Text('Submit Request')),
      ])),
    );
  }
  Widget _sec(String t, Widget c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 8), c]);
}