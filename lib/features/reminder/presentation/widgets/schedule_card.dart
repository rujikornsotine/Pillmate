import 'package:flutter/material.dart';

import '../../domain/entities/schedule.dart';

/// การ์ดแสดงข้อมูลตารางยาหนึ่งรายการ
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.onDelete,
  });

  final Schedule schedule;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const List<String> _weekdayLabels = [
    'จ',
    'อ',
    'พ',
    'พฤ',
    'ศ',
    'ส',
    'อา',
  ];

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String get _frequencySummary {
    switch (schedule.frequency) {
      case ScheduleFrequency.daily:
        return 'ทุกวัน · ${schedule.times.join(', ')}';
      case ScheduleFrequency.weekly:
        final days = schedule.weekdays
            .map((day) => _weekdayLabels[day - 1])
            .join(', ');
        return '$days · ${schedule.times.join(', ')}';
      case ScheduleFrequency.intervalHours:
        return 'ทุก ${schedule.intervalHours} ชม. เริ่ม ${schedule.startTime}';
      case ScheduleFrequency.everyNDays:
        return 'ทุก ${schedule.intervalDays} วัน · ${schedule.times.join(', ')}';
    }
  }

  String get _dateRangeSummary {
    final start = _formatDate(schedule.startDate);
    if (schedule.endDate == null) {
      return 'เริ่ม $start · ไม่มีกำหนดสิ้นสุด';
    }
    return '$start ถึง ${_formatDate(schedule.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.schedule_outlined,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(_frequencySummary),
        subtitle: Text(_dateRangeSummary),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'ลบตารางยา',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
