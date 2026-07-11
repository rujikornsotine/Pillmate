import '../../../../core/utils/result.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

/// แก้ไขตารางยาที่มีอยู่แล้ว พร้อมอัปเดตเวลาแก้ไขล่าสุด
class UpdateScheduleUseCase {
  UpdateScheduleUseCase({required ScheduleRepository repository})
    : _repository = repository;

  final ScheduleRepository _repository;

  Future<Result<void>> call({
    required Schedule existing,
    required ScheduleFrequency frequency,
    List<int> weekdays = const [],
    List<String> times = const [],
    int? intervalHours,
    String? startTime,
    int? intervalDays,
    required DateTime startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    // สร้าง Schedule ใหม่ตรงๆ แทนการใช้ copyWith เพราะฟิลด์ nullable
    // (intervalHours, startTime, intervalDays, endDate) อาจถูกล้างเป็น null ได้ตามรูปแบบที่เลือกใหม่
    final updated = Schedule(
      id: existing.id,
      medicationId: existing.medicationId,
      frequency: frequency,
      weekdays: weekdays,
      times: times,
      intervalHours: intervalHours,
      startTime: startTime,
      intervalDays: intervalDays,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive ?? existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return _repository.updateSchedule(updated);
  }
}
