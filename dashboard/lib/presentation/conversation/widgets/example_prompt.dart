import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/widgets/text.dart';

class ExamplePrompt extends StatelessWidget {
  const ExamplePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: 'Prueba con: "¿Qué sentí en esa navidad pasada?"',
      fontSize: 14,
      color: Colors.black.withOpacity(0.5),
      textAlign: TextAlign.center,
    );
  }
}
