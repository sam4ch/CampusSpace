import 'package:go_router/go_router.dart';

import 'screens/booking_detail_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/room_catalog_screen.dart';
import 'screens/room_detail_screen.dart';
import 'widgets/app_shell.dart';

// Built once, outside build. Restart after changing the route map.
final router = createRouter();

GoRouter createRouter({String initialLocation = '/login'}) => GoRouter(
  initialLocation: initialLocation,
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rooms',
              builder: (context, state) => const RoomCatalogScreen(),
              routes: roomRoutes(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const MyBookingsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      BookingDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
              routes: roomRoutes(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Catalog and favorites share the same detail/form flow in their own stacks.
List<RouteBase> roomRoutes() => [
  GoRoute(
    path: ':id',
    builder: (context, state) =>
        RoomDetailScreen(id: state.pathParameters['id']!),
    routes: [
      GoRoute(
        path: 'booking',
        builder: (context, state) =>
            BookingFormScreen(roomId: state.pathParameters['id']!),
      ),
    ],
  ),
];
