import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/request_model.dart';
import '../providers/request_provider.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, provider, _) {
        final request = provider.getById(requestId);
        if (request == null) {
          return const Scaffold(body: Center(child: Text('Request not found')));
        }

        final statusColor = _statusColor(request.status);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text('Request Detail'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            actions: [
              PopupMenuButton<RequestStatus>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (status) {
                  provider.updateStatus(request.id, status);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to ${status.label}'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                itemBuilder: (_) => RequestStatus.values
                    .where((s) => s != request.status)
                    .map((s) => PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _statusColor(s),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(s.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: statusColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_statusIcon(request.status),
                          color: statusColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.status.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Tap ⋮ to\nupdate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Info Card
              _InfoCard(children: [
                _DetailRow(
                  icon: request.category.icon,
                  label: 'Category',
                  value: request.category.label,
                  isEmoji: true,
                ),
                _Divider(),
                _DetailRow(
                  icon: '🚪',
                  label: 'Room Number',
                  value: 'Room ${request.roomNumber}',
                  isEmoji: true,
                ),
                _Divider(),
                _DetailRow(
                  icon: '🕐',
                  label: 'Submitted',
                  value: _formatDate(request.createdAt),
                  isEmoji: true,
                ),
                _Divider(),
                _DetailRow(
                  icon: '🔖',
                  label: 'Request ID',
                  value: '#${request.id}',
                  isEmoji: true,
                ),
              ]),
              const SizedBox(height: 20),

              // Title & Description
              _InfoCard(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Issue Title',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF80868B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF80868B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF444746),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 20),

              // Danger Zone
              if (request.status != RequestStatus.cancelled &&
                  request.status != RequestStatus.resolved)
                OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context, provider, request),
                  icon: const Icon(Icons.cancel_outlined,
                      size: 18, color: Color(0xFFEA4335)),
                  label: const Text('Cancel Request',
                      style: TextStyle(
                          color: Color(0xFFEA4335),
                          fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFFEA4335)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, RequestProvider provider,
      RequestModel request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This will mark the request as cancelled. You can reopen it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStatus(request.id, RequestStatus.cancelled);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA4335),
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return const Color(0xFFF29900);
      case RequestStatus.inProgress:
        return const Color(0xFF1A73E8);
      case RequestStatus.resolved:
        return const Color(0xFF34A853);
      case RequestStatus.cancelled:
        return const Color(0xFF80868B);
    }
  }

  IconData _statusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_top_rounded;
      case RequestStatus.inProgress:
        return Icons.handyman_rounded;
      case RequestStatus.resolved:
        return Icons.check_circle_rounded;
      case RequestStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final bool isEmoji;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          isEmoji
              ? Text(icon, style: const TextStyle(fontSize: 18))
              : Icon(Icons.info_outline, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF80868B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF1F3F4));
  }
}