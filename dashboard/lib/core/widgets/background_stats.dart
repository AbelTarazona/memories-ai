import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';

class BackgroundStats extends StatelessWidget {
  const BackgroundStats({
    super.key,
    required this.child,
    this.color = AppColors.blue2,
  });

  final Widget child;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: child,
    );
  }
}
