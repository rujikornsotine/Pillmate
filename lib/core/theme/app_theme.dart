import 'package:flutter/material.dart';

/// ธีมกลางของแอปพลิเคชัน ใช้ Material 3 และรองรับตัวอักษรขนาดใหญ่สำหรับผู้สูงอายุ
///
/// โทนสีหลักเป็นน้ำเงินสด (#2B7FFF) ให้ตรงกับโลโก้ Pillmate และแนวทาง UX/UI ที่ออกแบบไว้
class AppTheme {
  AppTheme._();

  /// สีแบรนด์หลัก (น้ำเงิน) ใช้กับ header, ปุ่มหลัก และแท็บที่เลือก
  static const Color brandBlue = Color(0xFF2B7FFF);

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: brandBlue,
          brightness: Brightness.light,
        ).copyWith(
          // บังคับให้ primary เป็นน้ำเงินสดตรงตามดีไซน์ (ไม่ให้ Material ปรับโทนเอง)
          primary: brandBlue,
          onPrimary: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      appBarTheme: const AppBarTheme(centerTitle: true),

      // การ์ดมุมโค้งนุ่ม เงาเบา พื้นขาวล้วน (ไม่ให้ Material 3 เจือสีลงบนการ์ด)
      cardTheme: CardThemeData(
        elevation: 1,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x14101828),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // แถบนำทางล่าง (bottom navigation)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        height: 66,
        indicatorColor: brandBlue.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? brandBlue : const Color(0xFF71717B),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? brandBlue : const Color(0xFF71717B),
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
