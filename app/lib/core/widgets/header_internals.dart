import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/core/widgets/text.dart';

class AppHeaderInternal extends StatelessWidget {
  const AppHeaderInternal({
    super.key,
    this.activateShadow = false,
    required this.title,
    this.description,
  });

  final bool activateShadow;

  final String title;

  final String? description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: activateShadow
                  ? [
                      const Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26,
                      ),
                    ]
                  : null,
            ),
            if (description != null)
              AppText(
                text: description!,
              ),
          ],
        ),
      ],
    );
  }
}
