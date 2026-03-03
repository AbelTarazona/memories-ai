import 'package:flutter/material.dart';
import 'package:memories/core/widgets/text.dart';

class IaIndicator extends StatelessWidget {
  const IaIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent.withValues(alpha: 0.7)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: AppText(
                text: 'IA',
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
