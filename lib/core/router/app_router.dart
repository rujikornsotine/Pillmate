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

/// Navigator key ระดับแอป ใช้เปิด Dialog จากนอก widget tree ปกติได้ (เช่นตอนแตะ
/// การแจ้งเตือนแล้วต้องแสดง popup ยืนยันการทานยา)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// การตั้งค่าเส้นทางนำทางทั้งหมดของแอปพลิเคชัน
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'medications',
      builder: (context, state) => const MedicationListScreen(),
    ),
    GoRoute(
      path: '/medications/add',
      name: 'medication-add',
      builder: (context, state) => const AddMedicationScreen(),
    ),
    GoRoute(
      path: '/medications/edit',
      name: 'medication-edit',
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return EditMedicationScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules',
      name: 'medication-schedules',
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return ScheduleListScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules/add',
      name: 'schedule-add',
      builder: (context, state) {
        final medication = state.extra! as Medication;
        return AddScheduleScreen(medication: medication);
      },
    ),
    GoRoute(
      path: '/medications/schedules/edit',
      name: 'schedule-edit',
      builder: (context, state) {
        final (medication, schedule) =
            state.extra! as (Medication, Schedule);
        return EditScheduleScreen(medication: medication, schedule: schedule);
      },
    ),
    GoRoute(
      path: '/today',
      name: 'today',
      builder: (context, state) => const TodayDosesScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const MedicationHistoryScreen(),
    ),
  ],
);
