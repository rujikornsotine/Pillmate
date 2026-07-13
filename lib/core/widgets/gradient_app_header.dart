import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Header โค้งมุมล่างพื้นน้ำเงินไล่เฉด ใช้แทน AppBar ธรรมดาในหน้าหลักแต่ละแท็บ
/// (ยาของฉัน / ยาวันนี้ / ประวัติ) ตามดีไซน์ UX/UI ที่ทำไว้
///
/// รองรับ [actions] เป็นปุ่มวงกลมโปร่งแสงมุมขวาบน และ [child] สำหรับเนื้อหาเพิ่มเติม
/// ใต้หัวข้อ (เช่น การ์ดสรุปสถิติ หรือแถบเลือกวัน)
class GradientAppHeader extends StatelessWidget {
  const GradientAppHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.child,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.brandBlue, AppTheme.brandBlueDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  HeaderIconCircle(icon: icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    ),
                  ],
                ],
              ),
              if (child != null) ...[
                const SizedBox(height: 20),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ปุ่ม/ไอคอนวงกลมพื้นขาวโปร่งแสง ใช้ทั้งไอคอนนำหน้าหัวข้อและปุ่ม action มุมขวาของ
/// [GradientAppHeader]
class HeaderIconCircle extends StatelessWidget {
  const HeaderIconCircle({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );

    if (onTap == null) return circle;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: circle),
    );
  }
}
