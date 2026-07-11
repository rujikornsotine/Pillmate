import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/medication.dart';

/// การ์ดแสดงข้อมูลยาหนึ่งรายการในหน้ารายการยา
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTap,
    required this.onSchedule,
    required this.onDelete,
  });

  final Medication medication;
  final VoidCallback onTap;
  final VoidCallback onSchedule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: medication.imagePath != null
              ? FileImage(File(medication.imagePath!))
              : null,
          child: medication.imagePath == null
              ? Icon(
                  Icons.medication_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                )
              : null,
        ),
        title: Text(medication.name),
        subtitle: Text('${medication.dosage} · ${medication.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.schedule_outlined),
              tooltip: 'ตารางยา',
              onPressed: onSchedule,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'ลบยา',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
