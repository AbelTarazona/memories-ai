import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memories/core/app_utils.dart';
import 'package:memories/core/widgets/text.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          text: AppUtils.getTime(),
          fontSize: 20,
        ),
        const SizedBox(width: 8),
        AppText(
          text: AppUtils.getDate(),
          fontSize: 20,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        Spacer(),
        //IaGeneratingIndicator(),
        Spacer(),
        SvgPicture.asset(
          'assets/images/head.svg',
          semanticsLabel: 'Head',
        ),
        const SizedBox(width: 2),
        AppText(
          text: 'Memories',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
