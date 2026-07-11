import '../../domain/entities/schedule.dart';
import '../models/schedule_model.dart';

/// แปลงข้อมูลระหว่าง Schedule (Domain Entity) และ ScheduleModel (Data Model)
class ScheduleMapper {
  ScheduleMapper._();

  /// แปลงจาก Entity เป็น Model เพื่อบันทึกลง Hive
  static ScheduleModel toModel(Schedule entity) {
    return ScheduleModel(
      id: entity.id,
      medicationId: entity.medicationId,
      frequency: entity.frequency.name,
      weekdays: entity.weekdays,
      times: entity.times,
      intervalHours: entity.intervalHours,
      startTime: entity.startTime,
      intervalDays: entity.intervalDays,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// แปลงจาก Model ที่อ่านจาก Hive เป็น Entity สำหรับใช้งานใน Domain/Presentation
  static Schedule toEntity(ScheduleModel model) {
    return Schedule(
      id: model.id,
      medicationId: model.medicationId,
      frequency: ScheduleFrequency.values.byName(model.frequency),
      weekdays: model.weekdays,
      times: model.times,
      intervalHours: model.intervalHours,
      startTime: model.startTime,
      intervalDays: model.intervalDays,
      startDate: model.startDate,
      endDate: model.endDate,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
