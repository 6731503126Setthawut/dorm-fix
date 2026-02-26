import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {
  pending, inProgress, resolved, cancelled;
  String get label {
    switch (this) {
      case RequestStatus.pending: return 'Pending';
      case RequestStatus.inProgress: return 'In Progress';
      case RequestStatus.resolved: return 'Resolved';
      case RequestStatus.cancelled: return 'Cancelled';
    }
  }
}

enum RequestCategory {
  electrical, plumbing, internet, aircon, furniture, other;
  String get label {
    switch (this) {
      case RequestCategory.electrical: return 'Electrical';
      case RequestCategory.plumbing: return 'Plumbing';
      case RequestCategory.internet: return 'Internet';
      case RequestCategory.aircon: return 'Air Con';
      case RequestCategory.furniture: return 'Furniture';
      case RequestCategory.other: return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case RequestCategory.electrical: return '⚡';
      case RequestCategory.plumbing: return '🔧';
      case RequestCategory.internet: return '📶';
      case RequestCategory.aircon: return '❄️';
      case RequestCategory.furniture: return '🪑';
      case RequestCategory.other: return '📋';
    }
  }
}

class RequestModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final RequestStatus status;
  final RequestCategory category;
  final String roomNumber;
  final DateTime createdAt;
  final List<String> imageUrls; // Firebase Storage URLs
  final String? adminNote;

  const RequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.roomNumber,
    required this.createdAt,
    this.imageUrls = const [],
    this.adminNote,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: RequestStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      category: RequestCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => RequestCategory.other,
      ),
      roomNumber: data['roomNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      adminNote: data['adminNote'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.name,
      'category': category.name,
      'roomNumber': roomNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrls': imageUrls,
      'adminNote': adminNote,
    };
  }

  RequestModel copyWith({
    String? id, String? userId, String? title, String? description,
    RequestStatus? status, RequestCategory? category, String? roomNumber,
    DateTime? createdAt, List<String>? imageUrls, String? adminNote,
  }) {
    return RequestModel(
      id: id ?? this.id, userId: userId ?? this.userId,
      title: title ?? this.title, description: description ?? this.description,
      status: status ?? this.status, category: category ?? this.category,
      roomNumber: roomNumber ?? this.roomNumber, createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls, adminNote: adminNote ?? this.adminNote,
    );
  }
}