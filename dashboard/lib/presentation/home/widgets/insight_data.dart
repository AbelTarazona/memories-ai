import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/widgets/background_stats.dart';
import 'package:memories_web_admin/core/widgets/text.dart';

class InsightData extends StatelessWidget {
  const InsightData({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return BackgroundStats(
      child: SizedBox(
        height: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontWeight: FontWeight.w600,
              color: AppColors.blue,
              textAlign: TextAlign.start,
              maxLines: 2,
            ),
            const Spacer(),
            content,
          ],
        ),
      ),
    );
  }
}
