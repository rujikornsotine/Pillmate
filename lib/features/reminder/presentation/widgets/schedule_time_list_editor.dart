import 'package:flutter/material.dart';

import '../../../../core/utils/time_of_day_formatter.dart';

/// ตัวแก้ไขรายการเวลาทานยาในแต่ละวัน เพิ่ม/ลบได้หลายเวลา
class ScheduleTimeListEditor extends StatelessWidget {
  const ScheduleTimeListEditor({
    super.key,
    required this.times,
    required this.onChanged,
  });

  /// เวลารูปแบบ HH:mm เรียงตามลำดับที่เพิ่ม
  final List<String> times;
  final ValueChanged<List<String>> onChanged;

  Future<void> _addTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final formatted = TimeOfDayFormatter.format(picked);
    if (times.contains(formatted)) return;

    final updated = List<String>.from(times)..add(formatted);
    updated.sort();
    onChanged(updated);
  }

  void _removeTime(String time) {
    final updated = List<String>.from(times)..remove(time);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final time in times)
              Chip(label: Text(time), onDeleted: () => _removeTime(time)),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('เพิ่มเวลา'),
              onPressed: () => _addTime(context),
            ),
          ],
        ),
      ],
    );
  }
}
