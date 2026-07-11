import 'package:flutter/material.dart';

import '../../../history/domain/entities/medication_history.dart';
import '../../domain/entities/medication_dose.dart';

/// การ์ดแสดงมื้อยาหนึ่งมื้อในหน้ายาวันนี้ พร้อมปุ่มยืนยันการทาน (ถ้ายังไม่ทาน)
class DoseCard extends StatelessWidget {
  const DoseCard({
    super.key,
    required this.dose,
    required this.onMarkTaken,
    this.isSubmitting = false,
  });

  final MedicationDose dose;
  final VoidCallback onMarkTaken;

  /// true ระหว่างกำลังบันทึกมื้อนี้ ใช้ปิดปุ่มกันกดซ้ำ
  final bool isSubmitting;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medication = dose.medication;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(dose.scheduledAt),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (dose.status == IntakeStatus.snoozed)
                  Text(
                    'เลื่อนแล้ว',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${medication.dosage} · ${medication.quantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildTrailing(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    if (dose.isTaken) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 4),
          Text('ทานแล้ว', style: TextStyle(color: Colors.green)),
        ],
      );
    }

    return FilledButton(
      onPressed: isSubmitting ? null : onMarkTaken,
      child: isSubmitting
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('ทานแล้ว'),
    );
  }
}
