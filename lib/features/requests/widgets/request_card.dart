import 'package:flutter/material.dart';
import '../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback? onTap;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);
    final statusBg = statusColor.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDADCE0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryBadge(category: request.category),
                  const Spacer(),
                  _StatusChip(
                    status: request.status,
                    color: statusColor,
                    backgroundColor: statusBg,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202124),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                request.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF80868B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined,
                      size: 14, color: Color(0xFF80868B)),
                  const SizedBox(width: 4),
                  Text(
                    'Room ${request.roomNumber}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF80868B),
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: Color(0xFF80868B)),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(request.createdAt),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF80868B)),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _CategoryBadge extends StatelessWidget {
  final RequestCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444746),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  final Color color;
  final Color backgroundColor;

  const _StatusChip({
    required this.status,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}