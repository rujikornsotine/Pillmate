import 'package:flutter/material.dart';

import '../../domain/entities/schedule.dart';

/// ตัวเลือกรูปแบบการรับประทานยาซ้ำ (ทุกวัน / รายสัปดาห์ / ทุก X ชั่วโมง)
class ScheduleFrequencySelector extends StatelessWidget {
  const ScheduleFrequencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ScheduleFrequency value;
  final ValueChanged<ScheduleFrequency> onChanged;

  String _labelOf(ScheduleFrequency frequency) {
    return switch (frequency) {
      ScheduleFrequency.daily => 'ทุกวัน',
      ScheduleFrequency.weekly => 'รายสัปดาห์',
      ScheduleFrequency.intervalHours => 'ทุก X ชั่วโมง',
      ScheduleFrequency.everyNDays => 'ทุก X วัน',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ScheduleFrequency>(
      segments: ScheduleFrequency.values
          .map(
            (frequency) => ButtonSegment(
              value: frequency,
              label: Text(_labelOf(frequency)),
            ),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
