/// Exception กลางที่ใช้ภายใน Data Layer เท่านั้น ห้ามโยนออกไปถึง UI Layer
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
