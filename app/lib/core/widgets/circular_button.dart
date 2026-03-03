import 'package:flutter/material.dart';

class CircularButton extends StatefulWidget {
  const CircularButton({super.key, required this.icon, required this.onTap});

  final Widget icon;

  final VoidCallback onTap;

  @override
  State<CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
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
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 1.09,
              color: Color(0xFF2171F1).withValues(alpha: 0.1),
            ),
            gradient: LinearGradient(
              begin: Alignment(0.00, -1.00),
              end: Alignment(0, 1),
              colors: [
                Color(0xFFFEFEFF),
                Color(0xFFD3E5FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2171F1).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: widget.icon,
        ),
      ),
    );
  }
}
