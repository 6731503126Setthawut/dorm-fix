import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../requests/models/request_model.dart';
import '../../requests/providers/request_provider.dart';
import '../../requests/widgets/request_card.dart';
import '../../../core/app_router.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  RequestStatus? _filter;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop()),
      ),
      body: Column(children: [
        // Search Bar
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by title, room, dorm...',
              hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB0B8C8), size: 20),
              suffixIcon: _search.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFFB0B8C8)),
                    onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
          
        // Filter chips
        SizedBox(height: 48, child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          scrollDirection: Axis.horizontal,
          itemCount: [null, ...RequestStatus.values].length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = i == 0 ? null : RequestStatus.values[i - 1];
            final sel = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1A73E8) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: sel ? [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : []),
                child: Text(f == null ? 'All' : f.label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF80868B)))));
          })),

        // List
        Expanded(child: StreamBuilder<List<RequestModel>>(
          stream: provider.allRequestsStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? [];
            var filtered = _filter == null ? all : all.where((r) => r.status == _filter).toList();
            if (_search.isNotEmpty) {
              filtered = filtered.where((r) =>
                r.title.toLowerCase().contains(_search) ||
                r.description.toLowerCase().contains(_search) ||
                r.roomNumber.toLowerCase().contains(_search) ||
                r.category.label.toLowerCase().contains(_search)).toList();
            }
            final pending = all.where((r) => r.status == RequestStatus.pending).length;
            final inProgress = all.where((r) => r.status == RequestStatus.inProgress).length;
            final resolved = all.where((r) => r.status == RequestStatus.resolved).length;

            return Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Row(children: [
                _StatCard(label: 'Total', count: all.length, color: const Color(0xFF1A73E8)),
                const SizedBox(width: 8),
                _StatCard(label: 'Pending', count: pending, color: const Color(0xFFF29900)),
                const SizedBox(width: 8),
                _StatCard(label: 'In Progress', count: inProgress, color: const Color(0xFF1A73E8)),
                const SizedBox(width: 8),
                _StatCard(label: 'Resolved', count: resolved, color: const Color(0xFF34A853)),
              ])),
              Expanded(child: filtered.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_search.isNotEmpty || _filter != null ? '🔍' : '📭',
                      style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(_search.isNotEmpty || _filter != null ? 'No results found' : 'No requests yet',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    if (_search.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Try a different keyword', style: TextStyle(color: Color(0xFF80868B)))],
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => RequestCard(
                      request: filtered[i],
                      onTap: () => context.push(RouteNames.detailPath(filtered[i].id))))),
            ]);
          })),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label; final int count; final Color color;
  const _StatCard({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(children: [
      Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withOpacity(0.7))),
    ])));
}
