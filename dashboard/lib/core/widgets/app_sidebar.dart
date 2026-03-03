import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _navigateTo(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AppColors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _navigateTo(0),
                        icon: SvgPicture.asset(
                          'assets/head.svg',
                          semanticsLabel: 'Head',
                        ),
                      ),
                      AppText(
                        text: 'Memories',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ShadButton.ghost(
                    expands: true,
                    leading: Icon(
                      LucideIcons.house,
                      color: navigationShell.currentIndex == 0 ? AppColors.blue : null,
                      size: 18,
                    ),
                    backgroundColor: navigationShell.currentIndex == 0 ? AppColors.sideBarBackground : null,
                    child: AppText(
                      text: 'Inicio',
                      textAlign: TextAlign.start,
                      color: navigationShell.currentIndex == 0 ? AppColors.blue : AppColors.black,
                    ),
                    onPressed: () => _navigateTo(0),
                  ),
                  const SizedBox(height: 8),
                  ShadButton.ghost(
                    expands: true,
                    leading: Icon(
                      LucideIcons.messageCircleMore,
                      color: navigationShell.currentIndex == 1 ? AppColors.blue : null,
                      size: 18,
                    ),
                    backgroundColor: navigationShell.currentIndex == 1 ? AppColors.sideBarBackground : null,
                    child: AppText(
                      text: 'Conversa con tu memoria',
                      textAlign: TextAlign.start,
                      color: navigationShell.currentIndex == 1 ? AppColors.blue : AppColors.black,
                    ),
                    onPressed: () => _navigateTo(1),
                  ),
                  const SizedBox(height: 8),
                  ShadButton.ghost(
                    expands: true,
                    leading: Icon(
                      LucideIcons.bookOpen,
                      color: navigationShell.currentIndex == 2 ? AppColors.blue : null,
                      size: 18,
                    ),
                    backgroundColor: navigationShell.currentIndex == 2 ? AppColors.sideBarBackground : null,
                    child: AppText(
                      text: 'Memorias',
                      textAlign: TextAlign.start,
                      color: navigationShell.currentIndex == 2 ? AppColors.blue : AppColors.black,
                    ),
                    onPressed: () => _navigateTo(2),
                  ),
                  const SizedBox(height: 8),
                  ShadButton.ghost(
                    expands: true,
                    leading: Icon(
                      LucideIcons.users,
                      color: navigationShell.currentIndex == 3 ? AppColors.blue : null,
                      size: 18,
                    ),
                    backgroundColor: navigationShell.currentIndex == 3 ? AppColors.sideBarBackground : null,
                    child: AppText(
                      text: 'Personas',
                      textAlign: TextAlign.start,
                      color: navigationShell.currentIndex == 3 ? AppColors.blue : AppColors.black,
                    ),
                    onPressed: () => _navigateTo(3),
                  ),
                  /*                  ShadButton.ghost(
                    expands: true,
                    leading: Icon(LucideIcons.laptopMinimal),
                    child: const Text(
                      'Dispositivos',
                      textAlign: TextAlign.start,
                    ),
                    onPressed: () => _navigateTo(3),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
