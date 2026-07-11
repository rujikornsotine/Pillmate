import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/medication_dose.dart';
import '../providers/today_doses_providers.dart';
import '../widgets/dose_card.dart';

/// หน้าจอแสดงมื้อยาที่ต้องรับประทานวันนี้ พร้อมให้ยืนยันการทานเองได้
class TodayDosesScreen extends ConsumerStatefulWidget {
  const TodayDosesScreen({super.key});

  @override
  ConsumerState<TodayDosesScreen> createState() => _TodayDosesScreenState();
}

class _TodayDosesScreenState extends ConsumerState<TodayDosesScreen> {
  /// คีย์ของมื้อที่กำลังบันทึกอยู่ ใช้ปิดปุ่มเฉพาะมื้อนั้นกันกดซ้ำ
  final Set<String> _submitting = {};

  String _doseKey(MedicationDose dose) =>
      '${dose.medication.id}|${dose.scheduledAt.toIso8601String()}';

  Future<void> _handleMarkTaken(MedicationDose dose) async {
    final key = _doseKey(dose);
    setState(() => _submitting.add(key));

    final result = await ref
        .read(todayDosesProvider.notifier)
        .markDoseTaken(dose);

    if (!mounted) return;
    setState(() => _submitting.remove(key));

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกการทาน ${dose.medication.name} แล้ว')),
        );
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
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(todayDosesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ยาวันนี้')),
      body: dosesAsync.when(
        data: (doses) {
          if (doses.isEmpty) {
            return const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'วันนี้ไม่มีมื้อยาที่ต้องทาน',
              message: 'เพิ่มตารางยาให้ยาของคุณเพื่อดูมื้อที่ต้องทานที่นี่',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(todayDosesProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doses.length,
              itemBuilder: (context, index) {
                final dose = doses[index];
                return DoseCard(
                  dose: dose,
                  isSubmitting: _submitting.contains(_doseKey(dose)),
                  onMarkTaken: () => _handleMarkTaken(dose),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'โหลดมื้อยาวันนี้ไม่สำเร็จ',
          message: error.toString(),
        ),
      ),
    );
  }
}
