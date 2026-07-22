import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/reminder_constants.dart';

/// ข้อมูลที่แนบไปกับการแจ้งเตือนแต่ละรายการ ใช้สร้างเนื้อหาการแจ้งเตือน "เลื่อน" ใหม่,
/// ยกเลิกการแจ้งเตือนซ้ำ, และบันทึกประวัติการทานยาได้โดยไม่ต้องเข้าถึง Hive
/// ผ่าน Repository ปกติ (จำเป็นสำหรับกรณีที่ผู้ใช้กดปุ่มขณะแอปไม่ได้เปิดอยู่)
class ReminderPayload {
  const ReminderPayload({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.quantity,
    required this.scheduledAt,
    this.followUpId,
  });

  final String medicationId;
  final String medicationName;
  final String dosage;
  final String quantity;

  /// เวลาที่ควรทานยาตามตารางเดิม (ไม่ใช่เวลาที่กดปุ่ม)
  final DateTime scheduledAt;

  /// id ของการแจ้งเตือนซ้ำที่ต้องยกเลิกเมื่อกด "ทานแล้ว" (ไม่มีค่าสำหรับการแจ้งเตือนที่เลื่อนแล้ว)
  final int? followUpId;

  String encode() => jsonEncode({
    'medicationId': medicationId,
    'medicationName': medicationName,
    'dosage': dosage,
    'quantity': quantity,
    'scheduledAt': scheduledAt.toIso8601String(),
    if (followUpId != null) 'followUpId': followUpId,
  });

  static ReminderPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPayload(
        medicationId: map['medicationId'] as String,
        medicationName: map['medicationName'] as String,
        dosage: map['dosage'] as String,
        quantity: map['quantity'] as String,
        scheduledAt: DateTime.parse(map['scheduledAt'] as String),
        followUpId: map['followUpId'] as int?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// เหตุการณ์ที่เกิดขึ้นเมื่อผู้ใช้โต้ตอบกับการแจ้งเตือน ไม่ว่าจะกดปุ่ม "ทานแล้ว"/"เลื่อน"
/// หรือแตะที่ตัวการแจ้งเตือนโดยตรง (actionId จะเป็น [ReminderConstants.actionOpen])
typedef ReminderActionEvent = ({ReminderPayload payload, String actionId});

/// จัดการการแจ้งเตือนทานยาทั้งหมดผ่าน flutter_local_notifications
/// ห้ามเรียก flutter_local_notifications จากที่อื่นนอกเหนือจาก Service นี้
class NotificationService {
  /// รหัส error ที่ปลั๊กอินโยนออกมาเมื่อสั่งปลุกตรงเวลาโดยที่ยังไม่ได้รับสิทธิ์
  static const String _exactAlarmsNotPermittedCode = 'exact_alarms_not_permitted';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  final StreamController<ReminderActionEvent> _actionController =
      StreamController<ReminderActionEvent>.broadcast();

  /// สตรีมเหตุการณ์กดปุ่มบนการแจ้งเตือน ใช้ฟังตอนแอปทำงานอยู่เพื่อบันทึกประวัติ
  /// ผ่าน Repository ตามสถาปัตยกรรมปกติ (กรณีแอปไม่ได้เปิดอยู่ต้องจัดการแยกต่างหาก
  /// ผ่าน onBackgroundResponse เนื่องจาก background isolate ไม่สามารถรับสตรีมนี้ได้)
  Stream<ReminderActionEvent> get actionEvents => _actionController.stream;

  /// ตั้งค่าฐานข้อมูล time zone ให้พร้อมใช้งาน ต้องเรียกในทุก isolate ที่จะใช้
  /// tz.TZDateTime (รวมถึง background isolate ที่แยกหน่วยความจำจาก isolate หลัก)
  static void ensureTimeZoneInitialized() {
    tz_data.initializeTimeZones();
    // แอปนี้ออกแบบสำหรับผู้ใช้งานในประเทศไทยเท่านั้นตาม requirements.md
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));
  }

  /// เตรียมปลั๊กอินแจ้งเตือน ต้องเรียกก่อนใช้งานเมธอดอื่นทั้งหมด
  ///
  /// [onBackgroundResponse] ต้องเป็น top-level function พร้อม
  /// @pragma('vm:entry-point') ตามข้อกำหนดของปลั๊กอิน กำหนดจากภายนอก (ไม่ใช่ใน
  /// Service นี้) เพราะ background isolate ต้องการเข้าถึง Hive ของ Feature อื่น
  /// (เช่นบันทึกประวัติการทานยา) ซึ่งไม่ควรเป็นความรับผิดชอบของ core service นี้
  Future<void> initialize({
    required DidReceiveBackgroundNotificationResponseCallback
    onBackgroundResponse,
  }) async {
    if (_isInitialized) return;

    ensureTimeZoneInitialized();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          ReminderConstants.darwinCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              ReminderConstants.actionMarkAsTaken,
              'ทานแล้ว',
            ),
            DarwinNotificationAction.plain(
              ReminderConstants.actionSnooze,
              'เลื่อน 15 นาที',
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      settings: InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );

    _isInitialized = true;
  }

  /// ขอสิทธิ์แสดงการแจ้งเตือนจากผู้ใช้งาน คืนค่า true ถ้าได้รับอนุญาต
  ///
  /// ขอเฉพาะสิทธิ์แสดงการแจ้งเตือนเท่านั้น (เป็น dialog ในแอป) ไม่รวมสิทธิ์
  /// การปลุกตรงเวลา เพราะสิทธิ์นั้นต้องพาผู้ใช้ออกไปหน้าตั้งค่าของระบบ
  /// จึงต้องอธิบายเหตุผลก่อนแล้วให้ผู้ใช้กดเอง (ดู [requestExactAlarmsPermission])
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      return await androidPlugin.requestNotificationsPermission() ?? false;
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// พาผู้ใช้ไปหน้าตั้งค่าการปลุกตรงเวลาของระบบ แล้วคืนค่าสถานะหลังผู้ใช้กลับมา
  ///
  /// ต้องเรียกหลังจากอธิบายเหตุผลให้ผู้ใช้เข้าใจแล้วเท่านั้น เพราะผู้ใช้จะถูกพา
  /// ออกจากแอปไปหน้าตั้งค่าของระบบโดยไม่มีคำอธิบายใดๆ จากฝั่งระบบเอง
  Future<bool> requestExactAlarmsPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true;

    return await androidPlugin.requestExactAlarmsPermission() ?? false;
  }

  /// ตรวจว่าแอปได้รับอนุญาตให้แสดงการแจ้งเตือนอยู่หรือไม่
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final options = await iosPlugin.checkPermissions();
      return options?.isEnabled ?? false;
    }

    return true;
  }

  /// ตรวจว่าแอปตั้งการปลุกแบบตรงเวลาได้หรือไม่
  ///
  /// Android 12 ขึ้นไปมีสิทธิ์นี้แยกต่างหาก และตั้งแต่ Android 14 จะไม่อนุญาต
  /// ให้อัตโนมัติอีกต่อไป ถ้าไม่ได้รับอนุญาตแล้วยังสั่งปลุกแบบตรงเวลา ปลั๊กอิน
  /// จะโยน PlatformException ทันที
  Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true;

    return await androidPlugin.canScheduleExactNotifications() ?? false;
  }

  /// ตั้งเวลาแจ้งเตือนทานยาหนึ่งมื้อ พร้อมแจ้งเตือนซ้ำอัตโนมัติถ้ายังไม่กดยืนยัน
  ///
  /// [useExactAlarm] ให้ส่งผลของ [canScheduleExactAlarms] เข้ามา ผู้เรียกควรถามครั้งเดียว
  /// ต่อการ sync หนึ่งรอบแล้วส่งต่อ ไม่ต้องถามใหม่ทุกมื้อ
  Future<void> scheduleDoseReminder({
    required String medicationId,
    required DateTime occurrence,
    required String medicationName,
    required String dosage,
    required String quantity,
    required bool useExactAlarm,
  }) async {
    final primaryId = _idFor(medicationId, occurrence, 'primary');
    final followUpId = _idFor(medicationId, occurrence, 'followup');

    final primaryPayload = ReminderPayload(
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      quantity: quantity,
      scheduledAt: occurrence,
      followUpId: followUpId,
    );
    final followUpPayload = ReminderPayload(
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      quantity: quantity,
      scheduledAt: occurrence,
    );

    await _scheduleAt(
      id: primaryId,
      dateTime: occurrence,
      title: 'ถึงเวลาทานยา: $medicationName',
      body: '$dosage · $quantity',
      payload: primaryPayload.encode(),
      useExactAlarm: useExactAlarm,
    );
    await _scheduleAt(
      id: followUpId,
      dateTime: occurrence.add(ReminderConstants.followUpDelay),
      title: 'ยังไม่ได้ยืนยันว่าทานยาแล้ว: $medicationName',
      body: '$dosage · $quantity',
      payload: followUpPayload.encode(),
      useExactAlarm: useExactAlarm,
    );
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
    required bool useExactAlarm,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    try {
      await _zonedSchedule(
        id: id,
        dateTime: dateTime,
        title: title,
        body: body,
        payload: payload,
        useExactAlarm: useExactAlarm,
      );
    } on PlatformException catch (error) {
      if (error.code != _exactAlarmsNotPermittedCode) rethrow;

      // สิทธิ์การปลุกตรงเวลาถูกเพิกถอนหลังจากที่ตรวจสอบไปแล้ว (ผู้ใช้ปิดเองระหว่าง
      // ที่แอปกำลังตั้งเวลาอยู่) ถอยไปใช้การปลุกแบบไม่ตรงเวลาแทน เพราะเตือนช้า
      // ไปไม่กี่นาทียังดีกว่าไม่เตือนเลย
      await _zonedSchedule(
        id: id,
        dateTime: dateTime,
        title: title,
        body: body,
        payload: payload,
        useExactAlarm: false,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
    required bool useExactAlarm,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      androidScheduleMode: useExactAlarm
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          ReminderConstants.androidChannelId,
          ReminderConstants.androidChannelName,
          channelDescription: ReminderConstants.androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            const AndroidNotificationAction(
              ReminderConstants.actionMarkAsTaken,
              'ทานแล้ว',
            ),
            const AndroidNotificationAction(
              ReminderConstants.actionSnooze,
              'เลื่อน 15 นาที',
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: ReminderConstants.darwinCategoryId,
        ),
      ),
    );
  }

  /// ยกเลิกการแจ้งเตือนตาม id
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// ยกเลิกการแจ้งเตือนทั้งหมดที่ตั้งเวลาไว้
  Future<void> cancelAll() => _plugin.cancelAll();

  /// ยกเลิกการแจ้งเตือนของมื้อยาหนึ่งมื้อ (ทั้งการแจ้งเตือนหลักและการแจ้งเตือนซ้ำ)
  /// ใช้เมื่อผู้ใช้ยืนยันการทานยามื้อนั้นเองในแอปแล้ว จึงไม่ต้องแจ้งเตือนอีก
  Future<void> cancelDoseReminder({
    required String medicationId,
    required DateTime occurrence,
  }) async {
    await _plugin.cancel(id: _idFor(medicationId, occurrence, 'primary'));
    await _plugin.cancel(id: _idFor(medicationId, occurrence, 'followup'));
  }

  /// ตรวจสอบว่าแอปถูกเปิดขึ้นมาจากการแตะที่การแจ้งเตือนหรือไม่ (กรณีแอปถูกปิดสนิท
  /// อยู่ก่อนหน้า) ต้องเรียกครั้งเดียวหลังจาก UI พร้อมใช้งานแล้ว (มี Navigator ให้แสดง
  /// popup ได้) เพื่อให้ได้ผลลัพธ์เดียวกับการแตะขณะแอปทำงานอยู่
  Future<void> checkAppLaunchDetails() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp == true && response != null) {
      _handleResponse(response);
    }
  }

  void _handleResponse(NotificationResponse response) {
    if (response.notificationResponseType ==
        NotificationResponseType.selectedNotification) {
      // ผู้ใช้แตะที่ตัวการแจ้งเตือนโดยตรง (ไม่ใช่ปุ่ม action) ไม่ต้องยกเลิก/เลื่อนเวลา
      // ใดๆ เอง แค่แจ้งให้ UI แสดง popup ยืนยันการทานยา
      final payload = ReminderPayload.decode(response.payload);
      if (payload != null) {
        _actionController.add((
          payload: payload,
          actionId: ReminderConstants.actionOpen,
        ));
      }
      return;
    }
    handleActionPlumbing(response);
  }

  /// ประมวลผลปุ่มที่ผู้ใช้กดบนการแจ้งเตือน (ยกเลิกการแจ้งเตือนซ้ำ / เลื่อนเวลา)
  /// และแจ้งผ่าน [actionEvents] ให้ส่วนอื่นบันทึกประวัติได้ (ถ้ามีผู้ฟังอยู่)
  ///
  /// เป็น public เพราะต้องเรียกได้จาก background isolate handler ที่นิยามไว้
  /// นอก Service นี้ (ดู [initialize])
  Future<void> handleActionPlumbing(NotificationResponse response) async {
    final payload = ReminderPayload.decode(response.payload);
    if (payload == null) return;
    final actionId = response.actionId;
    if (actionId == null) return;

    if (actionId == ReminderConstants.actionMarkAsTaken) {
      if (payload.followUpId != null) {
        await _plugin.cancel(id: payload.followUpId!);
      }
      _actionController.add((payload: payload, actionId: actionId));
      return;
    }

    if (actionId == ReminderConstants.actionSnooze) {
      if (payload.followUpId != null) {
        await _plugin.cancel(id: payload.followUpId!);
      }
      final snoozeTime = DateTime.now().add(ReminderConstants.snoozeDelay);
      final snoozeId = _idFor(
        'snooze',
        snoozeTime,
        '${payload.medicationId}-${response.id}',
      );
      await _scheduleAt(
        id: snoozeId,
        dateTime: snoozeTime,
        useExactAlarm: await canScheduleExactAlarms(),
        title: 'ถึงเวลาทานยา (เลื่อนแล้ว): ${payload.medicationName}',
        body: '${payload.dosage} · ${payload.quantity}',
        payload: ReminderPayload(
          medicationId: payload.medicationId,
          medicationName: payload.medicationName,
          dosage: payload.dosage,
          quantity: payload.quantity,
          scheduledAt: payload.scheduledAt,
        ).encode(),
      );
      _actionController.add((payload: payload, actionId: actionId));
    }
  }

  /// สร้าง id แบบ deterministic จาก key + เวลาที่แจ้งเตือน + ชนิดของการแจ้งเตือน
  /// เพื่อให้สามารถตั้งเวลาซ้ำ (sync ใหม่) ทับของเดิมได้โดยไม่สร้างรายการซ้ำซ้อน
  static int _idFor(String key, DateTime dateTime, String kind) {
    final composite = '$key|${dateTime.toIso8601String()}|$kind';
    return composite.hashCode & 0x7fffffff;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
