import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  const BackgroundScreen({super.key, required this.child, this.anchorKey});

  final Widget child;

  final GlobalKey? anchorKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          key: anchorKey,
          width: 720,
          height: 720,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEFEFF),
                Color(0xFFD3E5FF),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
