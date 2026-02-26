class DormData {
  static const Map<String, List<String>> zones = {
    'Zone L': ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'],
    'Zone F': ['F1', 'F2', 'F3', 'F4', 'F5', 'F6'],
    'Zone ST': ['ST1', 'ST2', 'ST3'],
    'Other': ['BS', 'PS'],
  };
  static List<String> get allDorms => zones.values.expand((e) => e).toList();
}
