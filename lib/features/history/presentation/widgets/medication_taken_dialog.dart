import 'package:flutter/material.dart';

/// Popup ยืนยันการทานยา แสดงเมื่อผู้ใช้แตะที่การแจ้งเตือนโดยตรง
class MedicationTakenDialog extends StatelessWidget {
  const MedicationTakenDialog({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.quantity,
  });

  final String medicationName;
  final String dosage;
  final String quantity;

  /// เปิด Dialog และคืนค่า true ถ้าผู้ใช้กด "ทานแล้ว"
  static Future<bool> show(
    BuildContext context, {
    required String medicationName,
    required String dosage,
    required String quantity,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MedicationTakenDialog(
        medicationName: medicationName,
        dosage: dosage,
        quantity: quantity,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.medication_outlined,
        size: 40,
        color: theme.colorScheme.primary,
      ),
      title: const Text('ถึงเวลาทานยา'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            medicationName,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text('$dosage · $quantity', textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('ปิด'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('ทานแล้ว'),
        ),
      ],
    );
  }
}
