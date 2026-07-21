import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/workspaces/presentation/workspace_collaboration_screen.dart';
import '../features/workspaces/presentation/workspace_invitation_response_screen.dart';
import 'shell/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.read(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authController,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublicRoute =
          location == '/login' ||
          location == '/signup' ||
          location == '/forgot-password';
      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';
      final isInvitationRoute = location == '/workspace-invitations/accept';

      return switch (authController.status) {
        AuthStatus.unknown => isSplash || isInvitationRoute ? null : '/splash',
        AuthStatus.unauthenticated =>
          isPublicRoute || isInvitationRoute ? null : '/login',
        AuthStatus.authenticated => _authenticatedRedirect(
          authController,
          isPublicRoute: isPublicRoute,
          isSplash: isSplash,
          isOnboarding: isOnboarding,
          isInvitationRoute: isInvitationRoute,
        ),
      };
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/workspace-invitations/accept',
        name: 'workspace-invitation-accept',
        builder: (context, state) => WorkspaceInvitationResponseScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: '/accounts/first',
        name: 'first-account',
        builder: (context, state) => const AccountsScreen(firstAccount: true),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TransactionsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReportsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'accounts',
                    name: 'accounts',
                    builder: (context, state) => const AccountsScreen(),
                  ),
                  GoRoute(
                    path: 'categories',
                    name: 'categories',
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'collaboration',
                    name: 'collaboration',
                    builder: (context, state) =>
                        const WorkspaceCollaborationScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String? _authenticatedRedirect(
  AuthController authController, {
  required bool isPublicRoute,
  required bool isSplash,
  required bool isOnboarding,
  required bool isInvitationRoute,
}) {
  if (isInvitationRoute) {
    return null;
  }

  if (authController.onboardingRequired) {
    return isOnboarding ? null : '/onboarding';
  }

  if (isPublicRoute || isSplash || isOnboarding) {
    return '/dashboard';
  }

  return null;
}
