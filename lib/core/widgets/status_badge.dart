import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// สีของ [StatusBadge] แต่ละแบบ ใช้สื่อความหมายสถานะการทานยา
enum StatusBadgeVariant {
  /// ทานแล้ว
  success,

  /// เลื่อนเวลา
  warning,

  /// ข้ามการทาน
  danger,

  /// ถึงเวลาทาน / ให้ความสนใจด้วยสีแบรนด์
  info,

  /// รอทาน หรือสถานะกลาง ๆ ที่ไม่ต้องเน้น
  neutral,
}

/// ป้ายสถานะทรงแคปซูล ใช้แสดงสถานะการทานยา (ทานแล้ว/เลื่อน/ข้าม/รอทาน ฯลฯ)
/// ตามดีไซน์ UX/UI ที่ทำไว้
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.variant});

  final String label;
  final StatusBadgeVariant variant;

  ({Color background, Color foreground}) _colorsFor(
    StatusBadgeVariant variant,
  ) {
    switch (variant) {
      case StatusBadgeVariant.success:
        return (
          background: const Color(0xFFD1FAE5),
          foreground: const Color(0xFF047857),
        );
      case StatusBadgeVariant.warning:
        return (
          background: const Color(0xFFFEF3C7),
          foreground: const Color(0xFFB45309),
        );
      case StatusBadgeVariant.danger:
        return (
          background: const Color(0xFFFEE2E2),
          foreground: const Color(0xFFB91C1C),
        );
      case StatusBadgeVariant.info:
        return (
          background: AppTheme.brandBlue.withValues(alpha: 0.1),
          foreground: AppTheme.brandBlue,
        );
      case StatusBadgeVariant.neutral:
        return (
          background: const Color(0xFFF4F4F5),
          foreground: const Color(0xFF71717B),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(variant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
