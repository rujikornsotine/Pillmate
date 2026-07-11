import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillmate/features/history/presentation/widgets/medication_taken_dialog.dart';

void main() {
  testWidgets('แสดงชื่อยา ขนาดยา และจำนวน', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => MedicationTakenDialog.show(
              context,
              medicationName: 'พาราเซตามอล',
              dosage: '500 mg',
              quantity: '1 เม็ด',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ถึงเวลาทานยา'), findsOneWidget);
    expect(find.text('พาราเซตามอล'), findsOneWidget);
    expect(find.text('500 mg · 1 เม็ด'), findsOneWidget);
    expect(find.text('ทานแล้ว'), findsOneWidget);
    expect(find.text('ปิด'), findsOneWidget);
  });

  testWidgets('กด "ทานแล้ว" คืนค่า true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await MedicationTakenDialog.show(
                context,
                medicationName: 'พาราเซตามอล',
                dosage: '500 mg',
                quantity: '1 เม็ด',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทานแล้ว'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('กด "ปิด" คืนค่า false', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await MedicationTakenDialog.show(
                context,
                medicationName: 'พาราเซตามอล',
                dosage: '500 mg',
                quantity: '1 เม็ด',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ปิด'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
