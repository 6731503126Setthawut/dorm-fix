import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../../auth/providers/auth_provider.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;
  
  const RequestDetailScreen({super.key, required this.requestId});

  Color _sc(RequestStatus s) { switch (s) { case RequestStatus.pending: return const Color(0xFFF29900); case RequestStatus.inProgress: return const Color(0xFF1A73E8); case RequestStatus.resolved: return const Color(0xFF34A853); case RequestStatus.cancelled: return const Color(0xFF80868B); } }
  IconData _si(RequestStatus s) { switch (s) { case RequestStatus.pending: return Icons.hourglass_top_rounded; case RequestStatus.inProgress: return Icons.handyman_rounded; case RequestStatus.resolved: return Icons.check_circle_rounded; case RequestStatus.cancelled: return Icons.cancel_rounded; } }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<RequestProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Request Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop()),
        actions: [if (auth.isAdmin) PopupMenuButton<RequestStatus>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (s) async {
            await provider.updateStatus(requestId, s);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Status updated to ${s.label}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16)));
          },
          itemBuilder: (_) => RequestStatus.values.map((s) => PopupMenuItem(value: s, child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: _sc(s), shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600))]))).toList())],
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: provider.allRequestsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final req = snap.data?.where((r) => r.id == requestId).firstOrNull;
          if (req == null) return const Center(child: Text('Request not found'));
          final sc = _sc(req.status);
          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          final h = req.createdAt.hour > 12 ? req.createdAt.hour - 12 : req.createdAt.hour == 0 ? 12 : req.createdAt.hour;
          final p = req.createdAt.hour >= 12 ? 'PM' : 'AM';
          final dateStr = '${req.createdAt.day} ${months[req.createdAt.month-1]} ${req.createdAt.year}, $h:${req.createdAt.minute.toString().padLeft(2,'0')} $p';

          return ListView(padding: const EdgeInsets.all(20), children: [
            // Status
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: sc.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: sc.withOpacity(0.25))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: sc.withOpacity(0.15), shape: BoxShape.circle), child: Icon(_si(req.status), color: sc, size: 22)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Current Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sc.withOpacity(0.8))),
                  Text(req.status.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: sc))])])),
            const SizedBox(height: 16),
            // Info
            _card([
              _row('🏷️', 'Category', req.category.label),
              const Divider(height: 1, color: Color(0xFFF1F3F4)),
              _row('🚪', 'Room', 'Room ${req.roomNumber}'),
              const Divider(height: 1, color: Color(0xFFF1F3F4)),
              _row('🕐', 'Submitted', dateStr)]),
            const SizedBox(height: 16),
            // Title + Desc
            _card([
              const Text('Issue Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF80868B))),
              const SizedBox(height: 6),
              Text(req.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF202124))),
              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF80868B))),
              const SizedBox(height: 6),
              Text(req.description, style: const TextStyle(fontSize: 14, color: Color(0xFF444746), height: 1.6))]),
            // Photos
            if (req.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              _card([
                const Text('Photos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF80868B))),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
                  children: req.imageUrls.map((url) => GestureDetector(
                    onTap: () => _showImage(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) => prog == null ? child : Container(color: const Color(0xFFF1F3F4), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F3F4), child: const Icon(Icons.broken_image_outlined, color: Color(0xFF80868B))))))).toList())]),
            ],
            // Admin Note
            if (req.adminNote != null) ...[
              const SizedBox(height: 16),
              _card([
                const Text('Admin Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF80868B))),
                const SizedBox(height: 6),
                Text(req.adminNote!, style: const TextStyle(fontSize: 14, color: Color(0xFF444746), height: 1.6))])],
            // Cancel button
            if (!auth.isAdmin && (req.status == RequestStatus.pending || req.status == RequestStatus.inProgress)) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Cancel Request?', style: TextStyle(fontWeight: FontWeight.w800)),
                  content: const Text('This will mark the request as cancelled.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep it')),
                    ElevatedButton(onPressed: () { provider.updateStatus(req.id, RequestStatus.cancelled); Navigator.pop(ctx); },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA4335), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                      child: const Text('Cancel'))])),
                icon: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFEA4335)),
                label: const Text('Cancel Request', style: TextStyle(color: Color(0xFFEA4335), fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: const BorderSide(color: Color(0xFFEA4335)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))],
          ]);
        }),
    );
  }

  void _showImage(BuildContext context, String url) {
    showDialog(context: context, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(url, fit: BoxFit.contain)))));
  }

  Widget _card(List<Widget> c) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFDADCE0))),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: c));

  Widget _row(String icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF80868B), fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF202124)))]));
}
