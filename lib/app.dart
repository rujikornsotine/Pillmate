import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/reminder_constants.dart';
import 'core/services/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/history/domain/entities/medication_history.dart';
import 'features/history/presentation/providers/medication_history_providers.dart';
import 'features/history/presentation/widgets/medication_taken_dialog.dart';
import 'features/reminder/presentation/providers/reminder_providers.dart';

/// Widget รากของแอปพลิเคชัน PillMate
class PillMateApp extends ConsumerStatefulWidget {
  const PillMateApp({super.key});

  @override
  ConsumerState<PillMateApp> createState() => _PillMateAppState();
}

class _PillMateAppState extends ConsumerState<PillMateApp> {
  StreamSubscription<ReminderActionEvent>? _actionSubscription;

  @override
  void initState() {
    super.initState();

    // ฟังเหตุการณ์กดปุ่ม "ทานแล้ว"/"เลื่อน" บนการแจ้งเตือนขณะแอปทำงานอยู่ เพื่อบันทึก
    // ประวัติผ่าน Repository ตามสถาปัตยกรรมปกติ (กรณีแอปไม่ได้เปิดอยู่จะถูกจัดการ
    // แยกต่างหากใน notification_background_handler.dart)
    _actionSubscription = ref
        .read(notificationServiceProvider)
        .actionEvents
        .listen(_handleReminderAction);

    // ขอสิทธิ์การแจ้งเตือนและตั้งเวลาแจ้งเตือนทั้งหมดใหม่ทุกครั้งที่เปิดแอป
    // (ไม่มี Background Task ทำงานตลอดเวลา จึงต้อง sync ใหม่ตอนเปิดแอปเสมอ)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(requestNotificationPermissionUseCaseProvider).call();
      await ref.read(syncRemindersUseCaseProvider).call();
      // ตรวจว่าแอปถูกเปิดขึ้นมาจากการแตะการแจ้งเตือนหรือไม่ (แอปถูกปิดสนิทมาก่อน)
      // ต้องเรียกหลังจากมี Navigator พร้อมแสดง popup แล้วเท่านั้น
      await ref.read(notificationServiceProvider).checkAppLaunchDetails();
    });
  }

  Future<void> _handleReminderAction(ReminderActionEvent event) async {
    if (event.actionId == ReminderConstants.actionOpen) {
      await _showTakenDialog(event.payload);
      return;
    }

    final status = event.actionId == ReminderConstants.actionMarkAsTaken
        ? IntakeStatus.taken
        : IntakeStatus.snoozed;

    await ref
        .read(recordMedicationIntakeUseCaseProvider)
        .call(
          medicationId: event.payload.medicationId,
          medicationName: event.payload.medicationName,
          scheduledAt: event.payload.scheduledAt,
          status: status,
        );
    ref.read(medicationHistoryListProvider.notifier).refresh();
  }

  /// แสดง popup ยืนยันการทานยาเมื่อผู้ใช้แตะที่การแจ้งเตือนโดยตรง กด "ทานแล้ว" จะ
  /// ยกเลิกการแจ้งเตือนซ้ำที่รออยู่ (ถ้ามี) และบันทึกประวัติเหมือนกดปุ่มบนการแจ้งเตือน
  Future<void> _showTakenDialog(ReminderPayload payload) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final confirmed = await MedicationTakenDialog.show(
      context,
      medicationName: payload.medicationName,
      dosage: payload.dosage,
      quantity: payload.quantity,
    );
    if (!confirmed) return;

    if (payload.followUpId != null) {
      await ref.read(notificationServiceProvider).cancel(payload.followUpId!);
    }
    await ref
        .read(recordMedicationIntakeUseCaseProvider)
        .call(
          medicationId: payload.medicationId,
          medicationName: payload.medicationName,
          scheduledAt: payload.scheduledAt,
          status: IntakeStatus.taken,
        );
    ref.read(medicationHistoryListProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _actionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pillmate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
