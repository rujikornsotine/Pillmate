import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../medication/domain/entities/medication.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_form.dart';

/// หน้าจอเพิ่มตารางยาใหม่สำหรับยารายการหนึ่ง
class AddScheduleScreen extends ConsumerStatefulWidget {
  const AddScheduleScreen({super.key, required this.medication});

  final Medication medication;

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit(ScheduleFormValues values) async {
    setState(() => _isSubmitting = true);

    final result = await ref
        .read(scheduleListProvider.notifier)
        .addSchedule(
          medicationId: widget.medication.id,
          frequency: values.frequency,
          weekdays: values.weekdays,
          times: values.times,
          intervalHours: values.intervalHours,
          startTime: values.startTime,
          intervalDays: values.intervalDays,
          startDate: values.startDate,
          endDate: values.endDate,
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
      appBar: AppBar(title: Text('เพิ่มตารางยา: ${widget.medication.name}')),
      body: ScheduleForm(
        submitLabel: 'บันทึก',
        isSubmitting: _isSubmitting,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
