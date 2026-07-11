import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/id_generator.dart';

/// จัดการการเลือกรูปภาพและจัดเก็บไฟล์รูปภาพถาวรในเครื่อง
/// UI ต้องเรียกผ่าน Service นี้เท่านั้น ห้ามเรียก image_picker หรือ dart:io โดยตรง
class ImageStorageService {
  ImageStorageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const String _folderName = 'medication_images';

  /// เปิดกล้องหรือคลังภาพเพื่อเลือกรูป คืนค่า path ชั่วคราวของไฟล์ที่เลือก หรือ null ถ้าผู้ใช้ยกเลิก
  Future<String?> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    return file?.path;
  }

  /// คัดลอกไฟล์รูปไปเก็บในโฟลเดอร์ถาวรของแอป ถ้า path ที่ให้มาอยู่ในโฟลเดอร์นี้อยู่แล้วจะคืนค่าเดิมโดยไม่คัดลอกซ้ำ
  Future<String> persist(String sourcePath) async {
    final directory = await _imagesDirectory();
    if (sourcePath.startsWith(directory.path)) {
      return sourcePath;
    }
    final fileName = '${IdGenerator.generate()}${_extensionOf(sourcePath)}';
    final savedPath = '${directory.path}${Platform.pathSeparator}$fileName';
    await File(sourcePath).copy(savedPath);
    return savedPath;
  }

  /// ลบไฟล์รูปภาพที่แอปจัดเก็บไว้ ไม่ลบไฟล์ที่อยู่นอกโฟลเดอร์ถาวรของแอป
  Future<void> delete(String? path) async {
    if (path == null) return;
    final directory = await _imagesDirectory();
    if (!path.startsWith(directory.path)) return;

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _imagesDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(
      '${documentsDir.path}${Platform.pathSeparator}$_folderName',
    );
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  String _extensionOf(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == filePath.length - 1) {
      return '.jpg';
    }
    return filePath.substring(dotIndex);
  }
}

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});
