import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/medication.dart';
import '../providers/medication_providers.dart';
import '../widgets/medication_form.dart';

/// หน้าจอแก้ไขข้อมูลยาที่มีอยู่แล้ว
class EditMedicationScreen extends ConsumerStatefulWidget {
  const EditMedicationScreen({super.key, required this.medication});

  final Medication medication;

  @override
  ConsumerState<EditMedicationScreen> createState() =>
      _EditMedicationScreenState();
}

class _EditMedicationScreenState extends ConsumerState<EditMedicationScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit(MedicationFormValues values) async {
    setState(() => _isSubmitting = true);

    final result = await ref
        .read(medicationListProvider.notifier)
        .editMedication(
          existing: widget.medication,
          name: values.name,
          dosage: values.dosage,
          quantity: values.quantity,
          note: values.note,
          imagePath: values.imagePath,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) => context.pop(),
      failure: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลยา')),
      body: MedicationForm(
        initial: widget.medication,
        submitLabel: 'บันทึกการแก้ไข',
        isSubmitting: _isSubmitting,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
