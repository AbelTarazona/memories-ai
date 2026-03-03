import 'package:flutter/material.dart';
import 'package:memories/core/app_colors.dart';
import 'package:memories/core/widgets/text.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: AppText(
              text: widget.title,
              color: AppColors.creme,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
