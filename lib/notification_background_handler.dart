import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/hive_boxes.dart';
import 'core/constants/reminder_constants.dart';
import 'core/services/notification_service.dart';
import 'core/utils/id_generator.dart';
import 'features/history/data/datasources/medication_history_local_data_source.dart';
import 'features/history/data/models/medication_history_model.dart';
import 'features/history/domain/entities/medication_history.dart';

/// Handler ที่ทำงานบน background isolate เมื่อผู้ใช้กดปุ่มบนการแจ้งเตือนขณะแอปไม่ได้เปิดอยู่
///
/// ต้องเป็น top-level function พร้อม @pragma('vm:entry-point') ตามข้อกำหนดของ
/// flutter_local_notifications เนื่องจาก background isolate แยกหน่วยความจำจาก
/// isolate หลักโดยสิ้นเชิง (ไม่มี ProviderContainer/Repository ให้เรียกใช้) จึงต้อง
/// เปิด Hive และเขียนข้อมูลตรงๆ ในไฟล์นี้แทนที่จะผ่านชั้น Repository ตามปกติ
/// นี่คือเหตุผลที่ไฟล์นี้อยู่นอก core/services (ซึ่งควรไม่รู้จัก Hive ของ Feature อื่น)
/// และนอกโฟลเดอร์ features/history (ซึ่งไม่ควรรู้จักรายละเอียดของ background isolate)
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  NotificationService.ensureTimeZoneInitialized();
  final service = NotificationService();
  // จัดการยกเลิก/เลื่อนเวลาแจ้งเตือนก่อนเสมอ ไม่ว่าการบันทึกประวัติจะสำเร็จหรือไม่
  unawaited(service.handleActionPlumbing(response));
  unawaited(_recordHistoryInBackground(response));
}

Future<void> _recordHistoryInBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  if (actionId != ReminderConstants.actionMarkAsTaken &&
      actionId != ReminderConstants.actionSnooze) {
    return;
  }

  final payload = ReminderPayload.decode(response.payload);
  if (payload == null) return;

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(HiveTypeIds.medicationHistoryModel)) {
      Hive.registerAdapter(MedicationHistoryModelAdapter());
    }
    final box = await MedicationHistoryLocalDataSource.openBox();
    final dataSource = MedicationHistoryLocalDataSource(box: box);

    final status = actionId == ReminderConstants.actionMarkAsTaken
        ? IntakeStatus.taken
        : IntakeStatus.snoozed;

    await dataSource.create(
      MedicationHistoryModel(
        id: IdGenerator.generate(),
        medicationId: payload.medicationId,
        medicationName: payload.medicationName,
        scheduledAt: payload.scheduledAt,
        recordedAt: DateTime.now(),
        status: status.name,
      ),
    );
  } catch (error) {
    debugPrint('บันทึกประวัติจาก background isolate ไม่สำเร็จ: $error');
  }
}
