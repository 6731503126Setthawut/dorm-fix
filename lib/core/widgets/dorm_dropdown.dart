import 'package:flutter/material.dart';
import '../dorm_data.dart';

class DormDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const DormDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];
    DormData.zones.forEach((zone, dorms) {
      items.add(DropdownMenuItem<String>(
        enabled: false, value: zone,
        child: Text(zone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1A73E8)))));
      for (final dorm in dorms) {
        items.add(DropdownMenuItem<String>(
          value: dorm,
          child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(dorm))));
      }
    });
    return DropdownButtonFormField<String>(
      value: value, isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.apartment_rounded, size: 20),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDADCE0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDADCE0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      hint: const Text('Select your dorm building'),
      items: items,
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select your dorm' : null);
  }
}