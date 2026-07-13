import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../medication/domain/entities/medication.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_card.dart';

/// หน้าจอแสดงตารางการทานยาทั้งหมดของยารายการหนึ่ง
class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key, required this.medication});

  final Medication medication;

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String scheduleId,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'ลบตารางยา',
      message: 'ต้องการลบตารางการทานยานี้ใช่หรือไม่',
      confirmLabel: 'ลบ',
      isDestructive: true,
    );
    if (!confirmed) return;

    final result = await ref
        .read(scheduleListProvider.notifier)
        .removeSchedule(scheduleId);

    if (!context.mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบตารางยาแล้ว')));
      },
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
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('ตารางยา: ${medication.name}')),
      body: schedulesAsync.when(
        data: (allSchedules) {
          final schedules = allSchedules
              .where((s) => s.medicationId == medication.id)
              .toList();

          if (schedules.isEmpty) {
            return const EmptyState(
              icon: Icons.schedule_outlined,
              title: 'ยังไม่มีตารางการทานยา',
              message: 'กดปุ่ม + เพื่อกำหนดเวลาทานยา',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(scheduleListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: schedules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ScheduleCard(
                  schedule: schedule,
                  onTap: () => context.push(
                    '/medications/schedules/edit',
                    extra: (medication, schedule),
                  ),
                  onDelete: () => _handleDelete(context, ref, schedule.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'โหลดข้อมูลตารางยาไม่สำเร็จ',
          message: error.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/medications/schedules/add', extra: medication),
        tooltip: 'เพิ่มตารางยา',
        child: const Icon(Icons.add),
      ),
    );
  }
}
