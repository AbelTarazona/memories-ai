import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppUserIcon extends StatelessWidget {
  const AppUserIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadAvatar(
          'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
          placeholder: Text('AT'),
          size: Size(30, 30),
        ),
        const SizedBox(width: 12),
        AppText(
          text: 'Abel Tarazona',
          fontSize: 16,
        ),
      ],
    );
  }
}
