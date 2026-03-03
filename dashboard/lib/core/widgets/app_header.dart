import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/widgets/app_user_icon.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.actions = const [],
  });

  final String? title;

  final bool showBackButton;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 26),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (title != null) ...[
                  AppText(
                    text: title!,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ] else ...[
                  if (showBackButton)
                    ShadButton.ghost(
                      size: ShadButtonSize.sm,
                      padding: EdgeInsets.only(
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      onPressed: () {
                        context.pop();
                        /*              final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                  } else {
                    router.go('/memories');
                  }*/
                      },
                      leading: const Icon(
                        LucideIcons.arrowLeft,
                        size: 18,
                      ),
                      child: AppText(
                        text: 'Regresar',
                        fontSize: 16,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...actions,
          AppUserIcon(),
        ],
      ),
    );
  }
}
