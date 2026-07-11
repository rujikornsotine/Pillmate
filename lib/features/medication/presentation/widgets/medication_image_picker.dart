import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/image_storage_service.dart';

enum _ImagePickerAction { camera, gallery, remove }

/// Widget เลือก/ถ่าย/ลบรูปยา แสดงเป็นวงกลมพร้อมปุ่มแก้ไขมุมล่างขวา
class MedicationImagePicker extends ConsumerWidget {
  const MedicationImagePicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
  });

  /// path รูปปัจจุบัน (อาจเป็น path ชั่วคราวที่ยังไม่ถูกบันทึกถาวร)
  final String? imagePath;
  final ValueChanged<String?> onChanged;

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_ImagePickerAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ถ่ายรูป'),
              onTap: () =>
                  Navigator.pop(sheetContext, _ImagePickerAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('เลือกจากคลังภาพ'),
              onTap: () =>
                  Navigator.pop(sheetContext, _ImagePickerAction.gallery),
            ),
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('ลบรูป'),
                onTap: () =>
                    Navigator.pop(sheetContext, _ImagePickerAction.remove),
              ),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == _ImagePickerAction.remove) {
      onChanged(null);
      return;
    }

    final source = action == _ImagePickerAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final pickedPath = await ref
        .read(imageStorageServiceProvider)
        .pickImage(source);
    if (pickedPath != null) {
      onChanged(pickedPath);
    }
  }

  void _openFullScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(imagePath!)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: GestureDetector(
        onTap: () => _handleTap(context, ref),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: imagePath != null
                  ? FileImage(File(imagePath!))
                  : null,
              child: imagePath == null
                  ? Icon(
                      Icons.medication_outlined,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            if (imagePath != null)
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _openFullScreen(context),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.secondary,
                    child: Icon(
                      Icons.zoom_in,
                      size: 16,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
