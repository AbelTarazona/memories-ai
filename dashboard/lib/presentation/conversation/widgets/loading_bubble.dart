import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 60,
        width: 60,
        child: Lottie.asset(
          'assets/lottie/chat-animation.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
