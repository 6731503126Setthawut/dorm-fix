import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/app_router.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../widgets/request_card.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  RequestStatus? _selectedFilter;

  static const _filters = <RequestStatus?>[
    null,
    RequestStatus.pending,
    RequestStatus.inProgress,
    RequestStatus.resolved,
    RequestStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSummaryRow(context),
            _buildFilterRow(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.create),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Request',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_greeting()}! 👋',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF80868B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'My Requests',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202124),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(RouteNames.login),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: const Icon(Icons.logout_rounded,
                  size: 20, color: Color(0xFF80868B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final total = provider.requests.length;
    final pending =
        provider.requests.where((r) => r.status == RequestStatus.pending).length;
    final inProgress = provider.requests
        .where((r) => r.status == RequestStatus.inProgress)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _SummaryCard(label: 'Total', count: total, color: const Color(0xFF1A73E8)),
          const SizedBox(width: 10),
          _SummaryCard(
              label: 'Pending', count: pending, color: const Color(0xFFF29900)),
          const SizedBox(width: 10),
          _SummaryCard(
              label: 'In Progress',
              count: inProgress,
              color: const Color(0xFF34A853)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          final label = filter == null ? 'All' : filter.label;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A73E8)
                      : const Color(0xFFDADCE0),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF80868B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) {
        final filtered = _selectedFilter == null
            ? provider.requests
            : provider.requests
                .where((r) => r.status == _selectedFilter)
                .toList();

        if (filtered.isEmpty) {
          return _buildEmpty();
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = filtered[index];
            return RequestCard(
              request: req,
              onTap: () => context.push(RouteNames.detailPath(req.id)),
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == null
                ? 'Tap "New Request" to report an issue.'
                : 'No ${_selectedFilter!.label.toLowerCase()} requests.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF80868B)),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}