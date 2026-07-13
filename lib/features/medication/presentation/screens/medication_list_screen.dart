import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_app_header.dart';
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

  Widget _buildTotalCard(int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ยาทั้งหมด',
              style: TextStyle(color: Color(0xFF71717B)),
            ),
            Text(
              '$total รายการ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationListProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientAppHeader(
            icon: Icons.medication_outlined,
            title: 'ยาของฉัน',
            subtitle: 'รายการยาทั้งหมดและสถานะการใช้งาน',
          ),
          Expanded(
            child: medicationsAsync.when(
              data: (medications) {
                if (medications.isEmpty) {
                  return const EmptyState(
                    icon: Icons.medication_outlined,
                    title: 'ยังไม่มีรายการยา',
                    message: 'กดปุ่ม + เพื่อเพิ่มยารายการแรกของคุณ',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(medicationListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: medications.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildTotalCard(medications.length);
                      }
                      final medication = medications[index - 1];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/medications/add'),
        tooltip: 'เพิ่มยา',
        child: const Icon(Icons.add),
      ),
    );
  }
}
