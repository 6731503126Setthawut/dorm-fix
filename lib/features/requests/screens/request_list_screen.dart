
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/request_card.dart';
import '../../../core/app_router.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> with TickerProviderStateMixin {
  RequestStatus? _filter;
  final _searchCtrl = TextEditingController();
  String _search = '';
  late AnimationController _headerAc;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = CurvedAnimation(parent: _headerAc, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAc, curve: Curves.easeOutCubic));
    _headerAc.forward();
  }

  @override
  void dispose() { _headerAc.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.read<RequestProvider>();
    final hour = DateTime.now().hour;
    final greeting = hour < 5 ? 'Good Night' : hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : hour < 21 ? 'Good Evening' : 'Good Night';
    final greetingEmoji = hour < 5 ? '🌙' : hour < 12 ? '☀️' : hour < 17 ? '👋' : hour < 21 ? '🌆' : '🌙';
    final name = auth.userModel?.name ?? 'there';
    final firstName = name.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(child: Column(children: [
        // Header Card
        FadeTransition(opacity: _headerFade, child: SlideTransition(position: _headerSlide, child:
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF1A73E8).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$greeting $greetingEmoji', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text('Room ${auth.userModel?.roomNumber ?? '-'}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ])),
                Row(children: [
                  if (auth.isAdmin)
                    GestureDetector(onTap: () => context.push(RouteNames.admin), child: Container(
                      margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.admin_panel_settings_rounded, size: 20, color: Colors.white))),
                  GestureDetector(onTap: () async { await context.read<AuthProvider>().logout(); if (context.mounted) context.go(RouteNames.login); },
                    child: Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.logout_rounded, size: 20, color: Colors.white))),
                ]),
              ]),
            ]),
          ))),

        // Search Bar
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child:
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search requests...',
              hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB0B8C8), size: 20),
              suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFFB0B8C8)), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); }) : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),

        // Filter chips
        SizedBox(height: 44, child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF80868B)))));
          })),
        const SizedBox(height: 8),

        // List
        Expanded(child: StreamBuilder<List<RequestModel>>(
          stream: provider.requestsStream(userId: auth.firebaseUser?.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)));
            }
            final all = snap.data ?? [];
            var filtered = _filter == null ? all : all.where((r) => r.status == _filter).toList();
            if (_search.isNotEmpty) {
              filtered = filtered.where((r) => r.title.toLowerCase().contains(_search) || r.description.toLowerCase().contains(_search) || r.category.label.toLowerCase().contains(_search)).toList();
            }
            final pending = all.where((r) => r.status == RequestStatus.pending).length;
            final inProgress = all.where((r) => r.status == RequestStatus.inProgress).length;
            return Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Row(children: [
                _StatCard(label: 'Total', count: all.length, color: const Color(0xFF1A73E8)),
                const SizedBox(width: 10),
                _StatCard(label: 'Pending', count: pending, color: const Color(0xFFF29900)),
                const SizedBox(width: 10),
                _StatCard(label: 'In Progress', count: inProgress, color: const Color(0xFF34A853)),
              ])),
              Expanded(child: filtered.isEmpty ? _EmptyState(hasSearch: _search.isNotEmpty || _filter != null) :
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 20), child: child)),
                    child: RequestCard(request: filtered[i], onTap: () => context.push(RouteNames.detailPath(filtered[i].id)))))),
            ]);
          })),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.create),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Request', style: TextStyle(fontWeight: FontWeight.w700))),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label; final int count; final Color color;
  const _StatCard({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(children: [
      Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withOpacity(0.7))),
    ])));
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 100, height: 100,
      decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.08), shape: BoxShape.circle),
      child: Center(child: Text(hasSearch ? '🔍' : '📭', style: const TextStyle(fontSize: 44)))),
    const SizedBox(height: 20),
    Text(hasSearch ? 'No results found' : 'No requests yet', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF202124))),
    const SizedBox(height: 8),
    Text(hasSearch ? 'Try a different keyword or filter' : 'Tap + to report your first issue',
      style: const TextStyle(fontSize: 14, color: Color(0xFF80868B))),
  ]));
}