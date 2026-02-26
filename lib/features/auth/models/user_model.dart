class UserModel {
  final String uid;
  final String email;
  final String name;
  final String roomNumber;
  final String role; // 'resident' | 'admin'
  final String? avatarUrl;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.roomNumber,
    this.role = 'resident',
    this.avatarUrl,
    this.fcmToken,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      role: map['role'] ?? 'resident',
      avatarUrl: map['avatarUrl'],
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'roomNumber': roomNumber,
      'role': role,
      'avatarUrl': avatarUrl,
      'fcmToken': fcmToken,
    };
  }
}