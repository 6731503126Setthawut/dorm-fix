class UserModel {
  final String uid;
  final String email;
  final String name;
  final String roomNumber;
  final String dormName;
  final String role;
  final String? fcmToken;

  UserModel({required this.uid, required this.email, required this.name,
    required this.roomNumber, this.dormName = '', this.role = 'resident', this.fcmToken});

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) => UserModel(
    uid: uid, email: map['email'] ?? '', name: map['name'] ?? '',
    roomNumber: map['roomNumber'] ?? '', dormName: map['dormName'] ?? '',
    role: map['role'] ?? 'resident', fcmToken: map['fcmToken']);

  Map<String, dynamic> toMap() => {
    'email': email, 'name': name, 'roomNumber': roomNumber,
    'dormName': dormName, 'role': role,
    if (fcmToken != null) 'fcmToken': fcmToken};

  UserModel copyWith({String? dormName, String? roomNumber}) => UserModel(
    uid: uid, email: email, name: name,
    roomNumber: roomNumber ?? this.roomNumber,
    dormName: dormName ?? this.dormName,
    role: role, fcmToken: fcmToken);
}