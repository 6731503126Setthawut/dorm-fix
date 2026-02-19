import 'package:flutter/foundation.dart';
import '../models/request_model.dart';

class RequestProvider extends ChangeNotifier {
  final List<RequestModel> _requests = [
    RequestModel(
      id: '1',
      title: 'Air conditioner not cooling',
      description:
          'The AC in my room has been running but not producing cold air for the past two days. Room temperature is very uncomfortable especially at night.',
      status: RequestStatus.inProgress,
      category: RequestCategory.aircon,
      roomNumber: '301',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RequestModel(
      id: '2',
      title: 'Leaking pipe under sink',
      description:
          'There is a slow drip from the pipe joint under the bathroom sink. There is water collecting on the floor of the cabinet below.',
      status: RequestStatus.pending,
      category: RequestCategory.plumbing,
      roomNumber: '301',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RequestModel(
      id: '3',
      title: 'Wi-Fi signal very weak',
      description:
          'Internet signal is barely reaching my room. I can barely get 1 bar and pages time out frequently. The issue started after last week\'s maintenance.',
      status: RequestStatus.resolved,
      category: RequestCategory.internet,
      roomNumber: '301',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    RequestModel(
      id: '4',
      title: 'Broken desk chair',
      description:
          'The back support of the study desk chair has snapped off. It\'s unsafe to sit on now. Need a replacement.',
      status: RequestStatus.pending,
      category: RequestCategory.furniture,
      roomNumber: '301',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RequestModel(
      id: '5',
      title: 'Power outlet not working',
      description:
          'The power outlet near the window is completely dead. I checked it with a phone charger and lamp — neither works. The other outlets in the room are fine.',
      status: RequestStatus.cancelled,
      category: RequestCategory.electrical,
      roomNumber: '301',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  List<RequestModel> get requests => List.unmodifiable(_requests);

  List<RequestModel> get pendingRequests =>
      _requests.where((r) => r.status == RequestStatus.pending).toList();

  List<RequestModel> get activeRequests => _requests
      .where((r) =>
          r.status == RequestStatus.pending ||
          r.status == RequestStatus.inProgress)
      .toList();

  RequestModel? getById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addRequest({
    required String title,
    required String description,
    required RequestCategory category,
    required String roomNumber,
  }) {
    final newRequest = RequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: RequestStatus.pending,
      category: category,
      roomNumber: roomNumber,
      createdAt: DateTime.now(),
    );
    _requests.insert(0, newRequest);
    notifyListeners();
  }

  void updateStatus(String id, RequestStatus newStatus) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void deleteRequest(String id) {
    _requests.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}