import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_app_header.dart';
import '../../domain/entities/medication_history.dart';
import '../providers/medication_history_providers.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/medication_history_card.dart';

/// หน้าจอแสดงประวัติการทานยา รองรับกรองตามช่วงเวลาและค้นหาชื่อยา
class MedicationHistoryScreen extends ConsumerStatefulWidget {
  const MedicationHistoryScreen({super.key});

  @override
  ConsumerState<MedicationHistoryScreen> createState() =>
      _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState
    extends ConsumerState<MedicationHistoryScreen> {
  /// ค่าเริ่มต้นเป็น "วันนี้" เพราะผู้ใช้ส่วนใหญ่เปิดหน้านี้เพื่อดูว่าวันนี้ทานยาครบหรือยัง
  HistoryPeriodFilter _period = HistoryPeriodFilter.today;
  String _searchQuery = '';

  bool _matchesPeriod(MedicationHistory history) {
    final now = DateTime.now();
    final scheduledAt = history.scheduledAt;
    switch (_period) {
      case HistoryPeriodFilter.all:
        return true;
      case HistoryPeriodFilter.today:
        return scheduledAt.year == now.year &&
            scheduledAt.month == now.month &&
            scheduledAt.day == now.day;
      case HistoryPeriodFilter.thisMonth:
        return scheduledAt.year == now.year && scheduledAt.month == now.month;
    }
  }

  bool _matchesSearch(MedicationHistory history) {
    if (_searchQuery.trim().isEmpty) return true;
    return history.medicationName.toLowerCase().contains(
      _searchQuery.trim().toLowerCase(),
    );
  }

  /// ข้อความ Empty State ให้สอดคล้องกับตัวกรองที่เลือกอยู่ กันผู้ใช้เข้าใจผิดว่าไม่มี
  /// ประวัติเลย ทั้งที่จริงแค่ไม่มีรายการในช่วงเวลาที่กรองอยู่
  String _emptyStateMessage() {
    if (_searchQuery.trim().isNotEmpty) {
      return 'ไม่พบยาที่ตรงกับคำค้นหาในช่วงเวลาที่เลือก';
    }
    return switch (_period) {
      HistoryPeriodFilter.all =>
        'ประวัติจะแสดงที่นี่เมื่อมีการยืนยันการทานยา',
      HistoryPeriodFilter.today =>
        'วันนี้ยังไม่มีการบันทึกการทานยา เลือก "ทั้งหมด" เพื่อดูประวัติย้อนหลัง',
      HistoryPeriodFilter.thisMonth =>
        'เดือนนี้ยังไม่มีการบันทึกการทานยา เลือก "ทั้งหมด" เพื่อดูประวัติย้อนหลัง',
    };
  }

  Widget _buildSummaryCard(List<MedicationHistory> filtered) {
    final taken = filtered
        .where((h) => h.status == IntakeStatus.taken)
        .length;
    final snoozed = filtered
        .where((h) => h.status == IntakeStatus.snoozed)
        .length;
    final skipped = filtered
        .where((h) => h.status == IntakeStatus.skipped)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สรุปตามตัวกรอง',
              style: TextStyle(color: Color(0xFF71717B)),
            ),
            const SizedBox(height: 4),
            Text(
              '${filtered.length} รายการ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStat('ทานแล้ว', taken)),
                Expanded(child: _buildStat('เลื่อน', snoozed)),
                Expanded(child: _buildStat('ข้าม', skipped)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF71717B)),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(medicationHistoryListProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientAppHeader(
            icon: Icons.history_outlined,
            title: 'ประวัติ',
            subtitle: 'บันทึกการทานยา การเลื่อน และการข้ามย้อนหลัง',
          ),
          HistoryFilterBar(
            period: _period,
            onPeriodChanged: (value) => setState(() => _period = value),
            onSearchChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: historyAsync.when(
              data: (history) {
                final filtered = history
                    .where(_matchesPeriod)
                    .where(_matchesSearch)
                    .toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.history_outlined,
                    title: 'ไม่พบประวัติการทานยา',
                    message: _emptyStateMessage(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(medicationHistoryListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSummaryCard(filtered);
                      }
                      return MedicationHistoryCard(
                        history: filtered[index - 1],
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => EmptyState(
                icon: Icons.error_outline,
                title: 'โหลดประวัติการทานยาไม่สำเร็จ',
                message: error.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
