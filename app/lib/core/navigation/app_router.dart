import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/data/models/full_screen_data.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/presentation/auth/bloc/auth_session_cubit.dart';
import 'package:memories/presentation/auth/login_page.dart';
import 'package:memories/presentation/auth/splash_page.dart';
import 'package:memories/presentation/fullscreen/full_screen_page.dart';
import 'package:memories/presentation/home/home_page.dart';
import 'package:memories/presentation/memories_list/memories_list_page.dart';
import 'package:memories/presentation/memories_list/memory_detail_page.dart';
import 'package:memories/presentation/record_memory/record_memory_page.dart';
import 'package:memories/presentation/settings/settings_page.dart';
import 'package:memories/presentation/voice_permission/voice_permission_page.dart';
import 'package:memories/core/services/voice_preferences.dart';

import 'go_router_refresh_stream.dart';

/// Centralized application router configuration.
class AppRouter {
  AppRouter({required AuthSessionCubit authSessionCubit})
    : _authSessionCubit = authSessionCubit;

  final AuthSessionCubit _authSessionCubit;

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(_authSessionCubit.stream),
    redirect: (context, state) async {
      // Verificar si ya completó el onboarding de voz
      final hasCompletedOnboarding =
          await VoicePreferences.hasCompletedOnboarding();
      final isOnVoicePermissionPage =
          state.matchedLocation == '/voice-permission';

      // Si no ha completado onboarding y no está en la página de permisos, redirigir
      if (!hasCompletedOnboarding && !isOnVoicePermissionPage) {
        return '/voice-permission';
      }

      return null;
    },
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
        path: '/voice-permission',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VoicePermissionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
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
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomePage(),
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
        path: '/fullscreen',
        pageBuilder: (context, state) {
          final data = state.extra as FullScreenData;
          return CustomTransitionPage(
            child: FullScreenPage(data: data),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: '/memories',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: MemoriesListPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (context, state) {
              final memory = state.pathParameters['id']!;
              final memoryId = int.tryParse(memory) ?? 0;
              return CustomTransitionPage(
                child: MemoryDetailPage(memoryId: memoryId),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/record-memory',
        pageBuilder: (context, state) {
          // Extraer el parámetro autoStart si viene en extra
          final extra = state.extra as Map<String, dynamic>?;
          final autoStart = extra?['autoStart'] as bool? ?? false;

          return CustomTransitionPage(
            child: RecordMemoryPage(autoStart: autoStart),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: SettingsPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],
  );
}
