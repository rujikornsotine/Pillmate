import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../medication/domain/entities/medication.dart';
import '../../domain/entities/schedule.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_form.dart';

/// หน้าจอแก้ไขตารางยาที่มีอยู่แล้ว
class EditScheduleScreen extends ConsumerStatefulWidget {
  const EditScheduleScreen({
    super.key,
    required this.medication,
    required this.schedule,
  });

  final Medication medication;
  final Schedule schedule;

  @override
  ConsumerState<EditScheduleScreen> createState() =>
      _EditScheduleScreenState();
}

class _EditScheduleScreenState extends ConsumerState<EditScheduleScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit(ScheduleFormValues values) async {
    setState(() => _isSubmitting = true);

    final result = await ref
        .read(scheduleListProvider.notifier)
        .editSchedule(
          existing: widget.schedule,
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
      appBar: AppBar(title: Text('แก้ไขตารางยา: ${widget.medication.name}')),
      body: ScheduleForm(
        initial: widget.schedule,
        submitLabel: 'บันทึกการแก้ไข',
        isSubmitting: _isSubmitting,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
