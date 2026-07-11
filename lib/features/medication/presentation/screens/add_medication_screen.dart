import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/medication_providers.dart';
import '../widgets/medication_form.dart';

/// หน้าจอเพิ่มยาใหม่
class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit(MedicationFormValues values) async {
    setState(() => _isSubmitting = true);

    final result = await ref
        .read(medicationListProvider.notifier)
        .addMedication(
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
      appBar: AppBar(title: const Text('เพิ่มยาใหม่')),
      body: MedicationForm(
        submitLabel: 'บันทึก',
        isSubmitting: _isSubmitting,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
