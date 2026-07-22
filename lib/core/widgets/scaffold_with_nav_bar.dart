import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// โครง Scaffold ที่ครอบทุกแท็บหลัก พร้อมแถบนำทางล่าง (bottom navigation)
///
/// ใช้ร่วมกับ StatefulShellRoute เพื่อคงสถานะของแต่ละแท็บไว้เมื่อสลับไปมา
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
    this.banner,
  });

  /// เชลล์นำทางที่ go_router ส่งมาให้ ใช้รู้แท็บปัจจุบันและสลับแท็บ
  final StatefulNavigationShell navigationShell;

  /// แถบแจ้งเตือนที่แสดงเหนือทุกแท็บ (ถ้ามี) รับมาจากภายนอกเพื่อให้ core ไม่ต้อง
  /// ผูกกับ Feature ใด Feature หนึ่ง — ผู้ประกอบร่างคือ app_router.dart
  final Widget? banner;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // แตะแท็บเดิมซ้ำ = กลับไปหน้าแรกสุดของแท็บนั้น
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: banner == null
          ? navigationShell
          : Column(
              children: [
                SafeArea(bottom: false, child: banner!),
                Expanded(child: navigationShell),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'ยาของฉัน',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'ยาวันนี้',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'ประวัติ',
          ),
        ],
      ),
    );
  }
}
