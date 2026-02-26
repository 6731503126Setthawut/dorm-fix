import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';

class RequestProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  static const _cloudName = 'dlwnynsgh';
  static const _uploadPreset = 'DormFix';
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<RequestModel>> requestsStream({String? userId}) {
    return _db.collection('requests').snapshots().map((s) {
      var list = s.docs.map(RequestModel.fromFirestore).toList();
      if (userId != null) list = list.where((r) => r.userId == userId).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<RequestModel>> allRequestsStream() {
    return _db.collection('requests').snapshots().map((s) {
      final list = s.docs.map(RequestModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: '${_uuid.v4()}.jpg'));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint('Cloudinary status: ${response.statusCode}');
      debugPrint('Cloudinary body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String?;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
    return null;
  }

  Future<void> addRequest({required String userId, required String title, required String description, required RequestCategory category, required String roomNumber, List<Uint8List> imageBytes = const []}) async {
    _setLoading(true);
    try {
      final urls = <String>[];
      for (final bytes in imageBytes) {
        final url = await uploadImage(bytes);
        if (url != null) urls.add(url);
        debugPrint('Uploaded URL: $url');
      }
      debugPrint('Total URLs: ${urls.length}');
      await _db.collection('requests').add(RequestModel(
        id: _uuid.v4(), userId: userId, title: title, description: description,
        status: RequestStatus.pending, category: category, roomNumber: roomNumber,
        createdAt: DateTime.now(), imageUrls: urls).toFirestore());
    } finally { _setLoading(false); }
  }

  Future<void> updateStatus(String id, RequestStatus status, {String? adminNote}) async {
    final update = <String, dynamic>{'status': status.name};
    if (adminNote != null) update['adminNote'] = adminNote;
    await _db.collection('requests').doc(id).update(update);
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
}
