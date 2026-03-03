import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/presentation/auth/bloc/auth_session_cubit.dart';
import 'package:memories_web_admin/presentation/auth/login_page.dart';
import 'package:memories_web_admin/presentation/auth/splash_page.dart';
import 'package:memories_web_admin/presentation/conversation/conversation_page.dart';
import 'package:memories_web_admin/presentation/devices/devices_page.dart';
import 'package:memories_web_admin/presentation/home/home_page.dart';
import 'package:memories_web_admin/presentation/main/main_page.dart';
import 'package:memories_web_admin/presentation/memories/memories_page.dart';
import 'package:memories_web_admin/presentation/memories/memory_detail_page.dart';
import 'package:memories_web_admin/presentation/people/people_page.dart';

import 'go_router_refresh_stream.dart';

/// Centralized application router configuration.
class AppRouter {
  AppRouter({required AuthSessionCubit authSessionCubit}) : _authSessionCubit = authSessionCubit;

  final AuthSessionCubit _authSessionCubit;

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(_authSessionCubit.stream),
    /*    redirect: (context, state) {
      final status = _authSessionCubit.state.status;
      final loggingIn = state.matchedLocation == '/login';
      final onSplash = state.matchedLocation == '/splash';

      if (status == AuthSessionStatus.loading || status == AuthSessionStatus.initial) {
        return onSplash ? null : '/splash';
      }

      final loggedIn = status == AuthSessionStatus.authenticated;

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn || onSplash) return '/';

      return null;
    },*/
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/conversation',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ConversationPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memories',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const MemoriesPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final memoryId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: MemoryDetailPage(memoryId: memoryId),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/people',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const PeoplePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/devices',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const DevicesPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
