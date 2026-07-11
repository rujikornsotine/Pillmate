import 'package:flutter/material.dart';

/// ตัวเลือกวันในสัปดาห์แบบเลือกได้หลายวัน (1 = จันทร์ ... 7 = อาทิตย์)
class ScheduleWeekdaySelector extends StatelessWidget {
  const ScheduleWeekdaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  static const List<String> _labels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  void _toggle(int weekday) {
    final updated = List<int>.from(selected);
    if (updated.contains(weekday)) {
      updated.remove(weekday);
    } else {
      updated.add(weekday);
    }
    updated.sort();
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        return FilterChip(
          label: Text(_labels[index]),
          selected: selected.contains(weekday),
          onSelected: (_) => _toggle(weekday),
        );
      }),
    );
  }
}
