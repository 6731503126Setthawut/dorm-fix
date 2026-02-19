enum RequestStatus {
  pending,
  inProgress,
  resolved,
  cancelled;

  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.resolved:
        return 'Resolved';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum RequestCategory {
  electrical,
  plumbing,
  internet,
  aircon,
  furniture,
  other;

  String get label {
    switch (this) {
      case RequestCategory.electrical:
        return 'Electrical';
      case RequestCategory.plumbing:
        return 'Plumbing';
      case RequestCategory.internet:
        return 'Internet';
      case RequestCategory.aircon:
        return 'Air Con';
      case RequestCategory.furniture:
        return 'Furniture';
      case RequestCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case RequestCategory.electrical:
        return '⚡';
      case RequestCategory.plumbing:
        return '🔧';
      case RequestCategory.internet:
        return '📶';
      case RequestCategory.aircon:
        return '❄️';
      case RequestCategory.furniture:
        return '🪑';
      case RequestCategory.other:
        return '📋';
    }
  }
}

class RequestModel {
  final String id;
  final String title;
  final String description;
  final RequestStatus status;
  final RequestCategory category;
  final String roomNumber;
  final DateTime createdAt;

  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.roomNumber,
    required this.createdAt,
  });

  RequestModel copyWith({
    String? id,
    String? title,
    String? description,
    RequestStatus? status,
    RequestCategory? category,
    String? roomNumber,
    DateTime? createdAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      roomNumber: roomNumber ?? this.roomNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}