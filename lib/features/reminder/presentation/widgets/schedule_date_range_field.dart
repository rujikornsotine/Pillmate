import 'package:flutter/material.dart';

/// ตัวเลือกวันที่เริ่มต้น (บังคับ) และวันที่สิ้นสุด (ไม่บังคับ) ของตารางยา
class ScheduleDateRangeField extends StatelessWidget {
  const ScheduleDateRangeField({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  String _format(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onStartDateChanged(picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onEndDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickStartDate(context),
            child: Text('เริ่ม ${_format(startDate)}'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickEndDate(context),
            child: Text(
              endDate == null ? 'ไม่มีกำหนดสิ้นสุด' : 'ถึง ${_format(endDate!)}',
            ),
          ),
        ),
        if (endDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'ล้างวันที่สิ้นสุด',
            onPressed: () => onEndDateChanged(null),
          ),
      ],
    );
  }
}
