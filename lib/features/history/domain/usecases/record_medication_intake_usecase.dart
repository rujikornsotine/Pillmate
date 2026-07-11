import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/medication_history.dart';
import '../repositories/medication_history_repository.dart';

/// บันทึกสถานะการรับประทานยาหนึ่งมื้อ (ทานแล้ว / เลื่อนการทาน / ข้ามการทาน)
class RecordMedicationIntakeUseCase {
  RecordMedicationIntakeUseCase({
    required MedicationHistoryRepository repository,
  }) : _repository = repository;

  final MedicationHistoryRepository _repository;

  Future<Result<void>> call({
    required String medicationId,
    required String medicationName,
    required DateTime scheduledAt,
    required IntakeStatus status,
  }) {
    final history = MedicationHistory(
      id: IdGenerator.generate(),
      medicationId: medicationId,
      medicationName: medicationName,
      scheduledAt: scheduledAt,
      recordedAt: DateTime.now(),
      status: status,
    );
    return _repository.recordIntake(history);
  }
}
