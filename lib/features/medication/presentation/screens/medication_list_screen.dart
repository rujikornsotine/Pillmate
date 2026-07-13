import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/medication_providers.dart';
import '../widgets/medication_card.dart';

/// หน้าจอแสดงรายการยาทั้งหมดของผู้ใช้งาน
class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'ลบยา',
      message: 'ต้องการลบ "$name" ออกจากรายการยาใช่หรือไม่',
      confirmLabel: 'ลบ',
      isDestructive: true,
    );
    if (!confirmed) return;

    final result = await ref
        .read(medicationListProvider.notifier)
        .removeMedication(id);

    if (!context.mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบ "$name" แล้ว')));
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
    final medicationsAsync = ref.watch(medicationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('รายการยาของฉัน')),
      body: medicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return const EmptyState(
              icon: Icons.medication_outlined,
              title: 'ยังไม่มีรายการยา',
              message: 'กดปุ่ม + เพื่อเพิ่มยารายการแรกของคุณ',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(medicationListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return MedicationCard(
                  medication: medication,
                  onTap: () => context.push(
                    '/medications/edit',
                    extra: medication,
                  ),
                  onSchedule: () => context.push(
                    '/medications/schedules',
                    extra: medication,
                  ),
                  onDelete: () => _handleDelete(
                    context,
                    ref,
                    medication.id,
                    medication.name,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'โหลดข้อมูลยาไม่สำเร็จ',
          message: error.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/medications/add'),
        tooltip: 'เพิ่มยา',
        child: const Icon(Icons.add),
      ),
    );
  }
}
