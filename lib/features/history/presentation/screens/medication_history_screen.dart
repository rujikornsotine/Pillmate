import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
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
  HistoryPeriodFilter _period = HistoryPeriodFilter.all;
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

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(medicationHistoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการทานยา')),
      body: Column(
        children: [
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
                  return const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'ไม่พบประวัติการทานยา',
                    message: 'ประวัติจะแสดงที่นี่เมื่อมีการยืนยันการทานยา',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(medicationHistoryListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        MedicationHistoryCard(history: filtered[index]),
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
