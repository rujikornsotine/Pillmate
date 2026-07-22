import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/reminder_permission_status.dart';
import '../providers/reminder_providers.dart';

/// แถบเตือนเมื่อสิทธิ์ที่จำเป็นต่อการแจ้งเตือนยังไม่ครบ พร้อมปุ่มขอสิทธิ์
///
/// ซ่อนตัวเองอัตโนมัติเมื่อได้รับสิทธิ์ครบแล้ว จึงวางไว้เหนือทุกแท็บได้โดยไม่รบกวน
/// ผู้ใช้ที่ตั้งค่าถูกต้องอยู่แล้ว
class ReminderPermissionBanner extends ConsumerStatefulWidget {
  const ReminderPermissionBanner({super.key});

  @override
  ConsumerState<ReminderPermissionBanner> createState() =>
      _ReminderPermissionBannerState();
}

class _ReminderPermissionBannerState
    extends ConsumerState<ReminderPermissionBanner> {
  /// กันกดปุ่มซ้ำระหว่างที่ยังรอผู้ใช้ตอบกลับจากหน้าตั้งค่าของระบบ
  bool _isRequesting = false;

  /// ข้อความสั้นบนแถบ บอกผลกระทบที่ผู้ใช้จะเจอจริงๆ ไม่ใช่ชื่อสิทธิ์ทางเทคนิค
  String _bannerMessage(ReminderPermissionStatus status) {
    if (!status.notificationsEnabled) {
      return 'แอปยังไม่ได้รับอนุญาตให้แจ้งเตือน คุณจะไม่ได้รับการเตือนทานยา';
    }
    return 'การเตือนทานยาอาจคลาดเคลื่อนจากเวลาที่ตั้งไว้ เพราะยังไม่ได้เปิดการปลุกตรงเวลา';
  }

  /// คำอธิบายฉบับเต็มก่อนพาผู้ใช้ออกไปหน้าตั้งค่าของระบบ ต้องบอกให้ชัดว่าจะเจออะไร
  /// เพราะหน้าตั้งค่าของ Android ไม่ได้อธิบายว่าแอปขอสิทธิ์นี้ไปทำอะไร
  String _rationaleMessage(ReminderPermissionStatus status) {
    final lines = <String>[];

    if (!status.notificationsEnabled) {
      lines.add(
        'PillMate ต้องได้รับอนุญาตให้แสดงการแจ้งเตือน จึงจะเตือนคุณตอนถึงเวลาทานยาได้',
      );
    }
    if (!status.exactAlarmsAllowed) {
      lines.add(
        'Android 14 ขึ้นไปจะไม่อนุญาตให้แอปปลุกตรงเวลาโดยอัตโนมัติ ถ้าไม่เปิดสิทธิ์นี้ '
        'ระบบจะเลื่อนเวลาเตือนไปรวมกับงานอื่นเพื่อประหยัดแบตเตอรี่ '
        'ทำให้การเตือนทานยาคลาดเคลื่อนได้หลายนาทีถึงหลายสิบนาที',
      );
      lines.add(
        'เมื่อกด "ไปตั้งค่า" ระบบจะพาไปหน้า "การปลุกและการช่วยเตือน" '
        'ให้เปิดสวิตช์ของ PillMate แล้วกดย้อนกลับมาที่แอป',
      );
    }

    return lines.join('\n\n');
  }

  Future<void> _handleRequest(ReminderPermissionStatus status) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'เปิดสิทธิ์การแจ้งเตือน',
      message: _rationaleMessage(status),
      confirmLabel: 'ไปตั้งค่า',
      cancelLabel: 'ไว้ก่อน',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isRequesting = true);
    await ref.read(reminderPermissionProvider.notifier)
        .requestMissingPermissions();
    if (!mounted) return;
    setState(() => _isRequesting = false);

    final updated = ref.read(reminderPermissionProvider).value;
    if (updated == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          updated.isFullyGranted
              ? 'เปิดสิทธิ์เรียบร้อย ตั้งเวลาแจ้งเตือนใหม่ให้แล้ว'
              : 'ยังเปิดสิทธิ์ไม่ครบ เปิดได้ภายหลังที่การตั้งค่าของเครื่อง',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(reminderPermissionProvider).value;
    if (status == null || !status.needsAttention) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    // ไม่ได้รับสิทธิ์แจ้งเตือนเลยถือว่าร้ายแรงกว่า เพราะจะไม่มีการเตือนใดๆ ทั้งสิ้น
    final isCritical = !status.notificationsEnabled;
    final background = isCritical
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = isCritical
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(
              isCritical
                  ? Icons.notifications_off_outlined
                  : Icons.alarm_outlined,
              color: foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _bannerMessage(status),
                style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ),
            const SizedBox(width: 8),
            if (_isRequesting)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: () => _handleRequest(status),
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: const Text('เปิดสิทธิ์'),
              ),
          ],
        ),
      ),
    );
  }
}
