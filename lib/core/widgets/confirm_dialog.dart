import 'package:flutter/material.dart';

/// Dialog ยืนยันการทำงานที่ไม่สามารถย้อนกลับได้ เช่น การลบข้อมูล
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'ยืนยัน',
    this.cancelLabel = 'ยกเลิก',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// เปิด dialog และคืนค่า true ถ้าผู้ใช้กดยืนยัน
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'ยืนยัน',
    String cancelLabel = 'ยกเลิก',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? theme.colorScheme.error : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
