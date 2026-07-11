import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

/// เพิ่มตารางยาใหม่ พร้อมสร้าง id และเวลาสร้าง/แก้ไขให้อัตโนมัติ
class CreateScheduleUseCase {
  CreateScheduleUseCase({required ScheduleRepository repository})
    : _repository = repository;

  final ScheduleRepository _repository;

  Future<Result<void>> call({
    required String medicationId,
    required ScheduleFrequency frequency,
    List<int> weekdays = const [],
    List<String> times = const [],
    int? intervalHours,
    String? startTime,
    int? intervalDays,
    required DateTime startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final schedule = Schedule(
      id: IdGenerator.generate(),
      medicationId: medicationId,
      frequency: frequency,
      weekdays: weekdays,
      times: times,
      intervalHours: intervalHours,
      startTime: startTime,
      intervalDays: intervalDays,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createSchedule(schedule);
  }
}
