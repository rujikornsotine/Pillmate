import 'package:flutter/material.dart';

/// ช่วงเวลาที่ใช้กรองประวัติการทานยา
enum HistoryPeriodFilter {
  /// ทั้งหมด
  all,

  /// วันนี้
  today,

  /// เดือนนี้
  thisMonth,
}

/// แถบกรองประวัติการทานยา ประกอบด้วยตัวเลือกช่วงเวลาและช่องค้นหาชื่อยา
class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.onSearchChanged,
  });

  final HistoryPeriodFilter period;
  final ValueChanged<HistoryPeriodFilter> onPeriodChanged;
  final ValueChanged<String> onSearchChanged;

  String _labelOf(HistoryPeriodFilter value) {
    return switch (value) {
      HistoryPeriodFilter.all => 'ทั้งหมด',
      HistoryPeriodFilter.today => 'วันนี้',
      HistoryPeriodFilter.thisMonth => 'เดือนนี้',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'ค้นหาชื่อยา',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<HistoryPeriodFilter>(
            segments: HistoryPeriodFilter.values
                .map(
                  (value) => ButtonSegment(
                    value: value,
                    label: Text(_labelOf(value)),
                  ),
                )
                .toList(),
            selected: {period},
            onSelectionChanged: (selection) =>
                onPeriodChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
