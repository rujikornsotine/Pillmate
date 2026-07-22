import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/today_doses_screen.dart';
import '../../features/history/presentation/screens/medication_history_screen.dart';
import '../../features/medication/domain/entities/medication.dart';
import '../../features/medication/presentation/screens/add_medication_screen.dart';
import '../../features/medication/presentation/screens/edit_medication_screen.dart';
import '../../features/medication/presentation/screens/medication_list_screen.dart';
import '../../features/reminder/domain/entities/schedule.dart';
import '../../features/reminder/presentation/screens/add_schedule_screen.dart';
import '../../features/reminder/presentation/screens/edit_schedule_screen.dart';
import '../../features/reminder/presentation/screens/schedule_list_screen.dart';
import '../../features/reminder/presentation/widgets/reminder_permission_banner.dart';
import '../widgets/scaffold_with_nav_bar.dart';

/// Navigator key ระดับแอป ใช้ push หน้าเต็มจอทับ bottom navigation และเปิด Dialog
/// จากนอก widget tree ปกติ (เช่นตอนแตะการแจ้งเตือนแล้วต้องแสดง popup ยืนยันการทานยา)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// การตั้งค่าเส้นทางนำทางทั้งหมดของแอปพลิเคชัน
///
/// 3 แท็บหลัก (ยาของฉัน / ยาวันนี้ / ประวัติ) อยู่ใน StatefulShellRoute เพื่อคงสถานะ
/// ของแต่ละแท็บและแสดง bottom navigation ร่วมกัน ส่วนหน้าเพิ่ม/แก้ไข/ตารางยาจะ push
/// เต็มจอทับ bottom navigation ผ่าน rootNavigatorKey
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ScaffoldWithNavBar(
        navigationShell: navigationShell,
        // แถบเตือนเรื่องสิทธิ์แจ้งเตือน ซ่อนตัวเองเมื่อสิทธิ์ครบแล้ว
        banner: const ReminderPermissionBanner(),
      ),
      branches: [
        // แท็บ 1: ยาของฉัน
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'medications',
              builder: (context, state) => const MedicationListScreen(),
            ),
          ],
        ),
        // แท็บ 2: ยาวันนี้
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              name: 'today',
              builder: (context, state) => const TodayDosesScreen(),
            ),
          ],
        ),
        // แท็บ 3: ประวัติ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const MedicationHistoryScreen(),
            ),
          ],
        ),
      ],
    ),

    // หน้าเต็มจอ (push ทับ bottom navigation)
    GoRoute(
      path: '/medications/add',
      name: 'medication-add',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddMedicationScreen(),
    ),
    GoRoute(
      path: '/medications/edit',
      name: 'medication-edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return EditMedicationScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules',
      name: 'medication-schedules',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return ScheduleListScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules/add',
      name: 'schedule-add',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return AddScheduleScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules/edit',
      name: 'schedule-edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final (medication, schedule) = state.extra! as (Medication, Schedule);
        return EditScheduleScreen(medication: medication, schedule: schedule);
      },
    ),
  ],
);
