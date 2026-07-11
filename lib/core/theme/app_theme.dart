import 'package:flutter/material.dart';

/// ธีมกลางของแอปพลิเคชัน ใช้ Material 3 และรองรับตัวอักษรขนาดใหญ่สำหรับผู้สูงอายุ
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
