import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'features/history/data/datasources/medication_history_local_data_source.dart';
import 'features/history/data/models/medication_history_model.dart';
import 'features/history/presentation/providers/medication_history_providers.dart';
import 'features/medication/data/datasources/medication_local_data_source.dart';
import 'features/medication/data/models/medication_model.dart';
import 'features/medication/presentation/providers/medication_providers.dart';
import 'features/reminder/data/datasources/schedule_local_data_source.dart';
import 'features/reminder/data/models/schedule_model.dart';
import 'features/reminder/presentation/providers/schedule_providers.dart';
import 'notification_background_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MedicationModelAdapter());
  Hive.registerAdapter(ScheduleModelAdapter());
  Hive.registerAdapter(MedicationHistoryModelAdapter());
  final medicationBox = await MedicationLocalDataSource.openBox();
  final scheduleBox = await ScheduleLocalDataSource.openBox();
  final historyBox = await MedicationHistoryLocalDataSource.openBox();

  final notificationService = NotificationService();
  await notificationService.initialize(
    onBackgroundResponse: notificationBackgroundHandler,
  );

  runApp(
    ProviderScope(
      overrides: [
        medicationBoxProvider.overrideWithValue(medicationBox),
        scheduleBoxProvider.overrideWithValue(scheduleBox),
        medicationHistoryBoxProvider.overrideWithValue(historyBox),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const PillMateApp(),
    ),
  );
}
