import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/screens/admin_content_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_events_screen.dart';
import '../features/admin/screens/admin_restaurants_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/dining/screens/dining_screen.dart';
import '../features/dining/screens/dish_detail_screen.dart';
import '../features/dining/screens/restaurant_detail_screen.dart';
import '../features/events/screens/event_detail_screen.dart';
import '../features/events/screens/events_calendar_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/recommendations_screen.dart';
import '../features/home/screens/saved_screen.dart';
import '../features/language/screens/phrase_show_mode_screen.dart';
import '../features/language/screens/phrase_detail_screen.dart';
import '../features/language/screens/phrasebook_screen.dart';
import '../features/map/screens/explore_map_screen.dart';
import '../features/map/screens/landmark_detail_screen.dart';
import '../features/map/screens/places_passed_screen.dart';
import '../features/map/screens/route_detail_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/scan/screens/scan_camera_screen.dart';
import '../features/scan/screens/scan_result_screen.dart';
import '../widgets/app_shell.dart';
import 'providers.dart';
import 'routes.dart';

/// Navigator that sits above the bottom navigation. Routes that use it
/// (chat, scan, admin, show mode) cover the whole screen and hide the tabs.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Builds the app's [GoRouter].
///
/// * The 5 tabs use a [StatefulShellRoute], so each tab keeps its own back
///   stack and scroll position when you switch tabs.
/// * [_redirect] is the single place that decides splash → onboarding →
///   login → tabs, and blocks non-admins from `/admin`.
/// * The router re-checks the redirect whenever [sessionProvider] changes.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref.read(sessionProvider), state),
    routes: [
      // ---------------- Entry flow ----------------
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),

      // ---------------- Bottom navigation (5 tabs) ----------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'recommendations',
                    builder: (context, state) => RecommendationsScreen(
                      becauseYouVisitedId: state.uri.queryParameters['from'],
                    ),
                  ),
                  GoRoute(
                    path: 'saved',
                    builder: (context, state) => const SavedScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const ProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: Dining
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dining,
                builder: (context, state) => const DiningScreen(),
                routes: [
                  GoRoute(
                    path: 'dish/:id',
                    builder: (context, state) =>
                        DishDetailScreen(dishId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'restaurant/:id',
                    builder: (context, state) => RestaurantDetailScreen(
                      restaurantId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 3: Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const ExploreMapScreen(),
                routes: [
                  GoRoute(
                    path: 'landmark/:id',
                    builder: (context, state) => LandmarkDetailScreen(
                      landmarkId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'places-passed',
                    builder: (context, state) => const PlacesPassedScreen(),
                  ),
                  GoRoute(
                    path: 'route/:id',
                    builder: (context, state) =>
                        RouteDetailScreen(routeId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          // Tab 4: Language
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.language,
                builder: (context, state) => const PhrasebookScreen(),
                routes: [
                  GoRoute(
                    path: 'phrase/:id',
                    builder: (context, state) => PhraseDetailScreen(
                      phraseId: state.pathParameters['id']!,
                    ),
                    routes: [
                      // Full screen, no bottom bar: uses the root navigator.
                      GoRoute(
                        path: 'show',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => PhraseShowModeScreen(
                          phraseId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Tab 5: Events
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.events,
                builder: (context, state) => const EventsCalendarScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        EventDetailScreen(eventId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ---------------- Full-screen pages (any tab) ----------------
      GoRoute(
        path: AppRoutes.chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ScanCameraScreen(
          initialMode: ScanMode.fromName(state.uri.queryParameters['mode']),
        ),
        routes: [
          GoRoute(
            path: 'result',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const ScanResultScreen(),
          ),
        ],
      ),

      // ---------------- Admin (guarded in _redirect) ----------------
      GoRoute(
        path: AppRoutes.admin,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'content',
            builder: (context, state) => const AdminContentScreen(),
          ),
          GoRoute(
            path: 'events',
            builder: (context, state) => const AdminEventsScreen(),
          ),
          GoRoute(
            path: 'restaurants',
            builder: (context, state) => const AdminRestaurantsScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Decides where the user is allowed to go. Returns `null` to stay put, or a
/// path to send the user somewhere else.
///
/// Order of checks: splash → first-run onboarding → login/guest → admin role.
String? _redirect(AppSession session, GoRouterState state) {
  final path = state.matchedLocation;
  final atSplash = path == AppRoutes.splash;
  final atOnboarding = path == AppRoutes.onboarding;
  final atLogin = path.startsWith(AppRoutes.login);

  // S1 must finish its sync check first.
  if (!session.splashDone) return atSplash ? null : AppRoutes.splash;

  // S2 only on the first run.
  if (!session.onboardingDone) {
    return atOnboarding ? null : AppRoutes.onboarding;
  }

  // S3 until the user signs in or chooses guest mode.
  if (!session.canEnterApp) return atLogin ? null : AppRoutes.login;

  // Already inside: never show splash/onboarding/login again.
  if (atSplash || atOnboarding || atLogin) return AppRoutes.home;

  // Admin screens are role-guarded (RLS also protects the data itself).
  if (path.startsWith(AppRoutes.admin) && !session.isAdmin) {
    return AppRoutes.home;
  }
  return null;
}