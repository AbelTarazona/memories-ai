import 'package:flutter/material.dart';

class SquareEmotionLevel extends StatelessWidget {
  const SquareEmotionLevel({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
