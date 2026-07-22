import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/medication_history.dart';

/// การ์ดแสดงประวัติการทานยาหนึ่งรายการ
class MedicationHistoryCard extends StatelessWidget {
  const MedicationHistoryCard({super.key, required this.history});

  final MedicationHistory history;

  ({IconData icon, Color color, String label, StatusBadgeVariant variant})
  get _statusInfo {
    switch (history.status) {
      case IntakeStatus.taken:
        return (
          icon: Icons.check_circle_outline,
          color: Colors.green,
          label: 'ทานแล้ว',
          variant: StatusBadgeVariant.success,
        );
      case IntakeStatus.snoozed:
        return (
          icon: Icons.snooze_outlined,
          color: Colors.orange,
          label: 'เลื่อน',
          variant: StatusBadgeVariant.warning,
        );
      case IntakeStatus.skipped:
        return (
          icon: Icons.cancel_outlined,
          color: Colors.red,
          label: 'ข้าม',
          variant: StatusBadgeVariant.danger,
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
    final statusInfo = _statusInfo;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusInfo.color.withValues(alpha: 0.15),
          child: Icon(statusInfo.icon, color: statusInfo.color),
        ),
        title: Text(history.medicationName),
        subtitle: Text('กำหนดทาน ${_formatDateTime(history.scheduledAt)}'),
        trailing: StatusBadge(
          label: statusInfo.label,
          variant: statusInfo.variant,
        ),
      ),
    );
  }
}
