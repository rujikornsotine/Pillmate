import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/presentation/providers/medication_providers.dart';
import 'package:pillmate/features/medication/presentation/screens/medication_list_screen.dart';

class _FakeEmptyNotifier extends MedicationListNotifier {
  @override
  Future<List<Medication>> build() async => [];
}

class _FakeMedicationNotifier extends MedicationListNotifier {
  @override
  Future<List<Medication>> build() async => [
    Medication(
      id: '1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];
}

void main() {
  testWidgets('แสดง Empty State เมื่อยังไม่มีรายการยา', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicationListProvider.overrideWith(_FakeEmptyNotifier.new),
        ],
        child: const MaterialApp(home: MedicationListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ยังไม่มีรายการยา'), findsOneWidget);
  });

  testWidgets('แสดงรายการยาเมื่อมีข้อมูล', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicationListProvider.overrideWith(_FakeMedicationNotifier.new),
        ],
        child: const MaterialApp(home: MedicationListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('พาราเซตามอล'), findsOneWidget);
    expect(find.text('500 mg · 1 เม็ด'), findsOneWidget);
  });
}
