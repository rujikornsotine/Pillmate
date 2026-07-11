import 'package:flutter/material.dart';

import '../../domain/entities/medication_history.dart';

/// การ์ดแสดงประวัติการทานยาหนึ่งรายการ
class MedicationHistoryCard extends StatelessWidget {
  const MedicationHistoryCard({super.key, required this.history});

  final MedicationHistory history;

  ({IconData icon, Color Function(ColorScheme) color, String label})
  get _statusInfo {
    switch (history.status) {
      case IntakeStatus.taken:
        return (
          icon: Icons.check_circle_outline,
          color: (scheme) => Colors.green,
          label: 'ทานแล้ว',
        );
      case IntakeStatus.snoozed:
        return (
          icon: Icons.snooze_outlined,
          color: (scheme) => Colors.orange,
          label: 'เลื่อนการทาน',
        );
      case IntakeStatus.skipped:
        return (
          icon: Icons.cancel_outlined,
          color: (scheme) => scheme.error,
          label: 'ข้ามการทาน',
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _statusInfo;
    final statusColor = statusInfo.color(theme.colorScheme);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(statusInfo.icon, color: statusColor),
        ),
        title: Text(history.medicationName),
        subtitle: Text('กำหนดทาน ${_formatDateTime(history.scheduledAt)}'),
        trailing: Chip(
          label: Text(statusInfo.label),
          labelStyle: TextStyle(color: statusColor),
          backgroundColor: statusColor.withValues(alpha: 0.1),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
