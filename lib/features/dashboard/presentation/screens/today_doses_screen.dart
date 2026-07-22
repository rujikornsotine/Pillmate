import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_app_header.dart';
import '../../domain/entities/medication_dose.dart';
import '../../../history/domain/entities/medication_history.dart';
import '../providers/today_doses_providers.dart';
import '../widgets/dose_card.dart';

const _thaiWeekdays = [
  'วันจันทร์',
  'วันอังคาร',
  'วันพุธ',
  'วันพฤหัสบดี',
  'วันศุกร์',
  'วันเสาร์',
  'วันอาทิตย์',
];

const _thaiMonths = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];

String _formatThaiDate(DateTime date) {
  final weekday = _thaiWeekdays[date.weekday - 1];
  final month = _thaiMonths[date.month - 1];
  return '$weekdayที่ ${date.day} $month';
}

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

  Widget _buildProgressCard(List<MedicationDose> doses) {
    final total = doses.length;
    final taken = doses.where((d) => d.status == IntakeStatus.taken).length;
    final snoozed = doses
        .where((d) => d.status == IntakeStatus.snoozed)
        .length;
    final pending = total - taken - snoozed;
    final progress = total == 0 ? 0.0 : taken / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ความคืบหน้าวันนี้',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$taken/$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFF4F4F5),
                valueColor: const AlwaysStoppedAnimation(AppTheme.brandBlue),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegend(Colors.green, 'ทานแล้ว $taken'),
                _buildLegend(Colors.orange, 'เลื่อน $snoozed'),
                _buildLegend(const Color(0xFFF4F4F5), 'รอทาน $pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF71717B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(todayDosesProvider);

    return Scaffold(
      body: Column(
        children: [
          GradientAppHeader(
            icon: Icons.medication_outlined,
            title: 'ยาวันนี้',
            subtitle: _formatThaiDate(DateTime.now()),
          ),
          Expanded(
            child: dosesAsync.when(
              data: (doses) {
                if (doses.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'วันนี้ไม่มีมื้อยาที่ต้องทาน',
                    message: 'เพิ่มตารางยาให้ยาของคุณเพื่อดูมื้อที่ต้องทานที่นี่',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(todayDosesProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: doses.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildProgressCard(doses);
                      }
                      final dose = doses[index - 1];
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
          ),
        ],
      ),
    );
  }
}
