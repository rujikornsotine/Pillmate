/// Pattern สำหรับห่อผลลัพธ์จาก Repository เพื่อไม่ให้ต้อง throw Exception ขึ้นไปที่ UI Layer
sealed class Result<T> {
  const Result();

  /// สร้างผลลัพธ์ที่สำเร็จ
  const factory Result.success(T data) = Success<T>;

  /// สร้างผลลัพธ์ที่ล้มเหลว
  const factory Result.failure(String message) = Failure<T>;

  /// true ถ้าผลลัพธ์สำเร็จ
  bool get isSuccess => this is Success<T>;

  /// true ถ้าผลลัพธ์ล้มเหลว
  bool get isFailure => this is Failure<T>;

  /// จัดการทั้งสองกรณีของผลลัพธ์พร้อมกัน
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    final result = this;
    if (result is Success<T>) {
      return success(result.data);
    }
    return failure((result as Failure<T>).message);
  }
}

/// ผลลัพธ์ที่สำเร็จพร้อมข้อมูล
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// ผลลัพธ์ที่ล้มเหลวพร้อมข้อความ error
final class Failure<T> extends Result<T> {
  const Failure(this.message);

  final String message;
}
