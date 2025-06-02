import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony_music/src/features/auth/presentation/screens/home_screen.dart';
import 'package:harmony_music/src/features/auth/presentation/screens/login_screen.dart';

import '../../features/local_music/music.dart';
import '../../features/splash/presentation/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter getGoRouterOfTheApp({String? initialRoute}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: MusicScreen.routeName,
    errorBuilder: (context, state) {
      return const Scaffold(body: Center(child: Text('Page not found')));
    },
    // refreshListenable: MarryGoRouterWithBloc(sl<AuthBloc>()),
    // redirect: (context, state) {
    //   String? token = sl<AuthBloc>().state.accessToken;
    //
    //   /// TODO: Prevent redirecting while loading
    //   /// Example:
    //   /// if (isLoading) {
    //   ///   return SplashScreen.routeName;
    //   /// }
    //
    //   if (token == null &&
    //       [
    //         SplashScreen.routeName,
    //         HomeScreen.routeName,
    //       ].contains(state.matchedLocation)) {
    //     return LoginScreen.routeName;
    //   } else if (token != null &&
    //       [
    //         SplashScreen.routeName,
    //         LoginScreen.routeName,
    //       ].contains(state.matchedLocation)) {
    //     return HomeScreen.routeName;
    //   } else {
    //     // To display the intended route without redirecting,
    //     // return null or the original route path.
    //     return null;
    //   }
    // },
    routes: [
      GoRoute(
        name: SplashScreen.routeName,
        path: SplashScreen.routeName,
        pageBuilder: (context, state) {
          return createCustomTransition(
            child: const SplashScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        name: LoginScreen.routeName,
        path: LoginScreen.routeName,
        pageBuilder: (context, state) {
          return createCustomTransition(
            child: const LoginScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        name: HomeScreen.routeName,
        path: HomeScreen.routeName,
        pageBuilder: (context, state) {
          return createCustomTransition(
            child: const HomeScreen(),
            key: state.pageKey,
          );
        },
      ),

      GoRoute(
        name: MusicScreen.routeName,
        path: MusicScreen.routeName,
        pageBuilder: (context, state) {
          return createCustomTransition(
            child: const MusicScreen(),
            key: state.pageKey,
          );
        },
      ),
    ],
  );
}

CustomTransitionPage<T> createCustomTransition<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut), // Smoother animation
          ),
        ),
        child: child,
      );
    },
  );
}

/// Converts a [Bloc] into a [Listenable]
///
/// ```dart
/// GoRouter(
///  refreshListenable: MarryGoRouterWithBloc(stream),
/// );
/// ```
class MarryGoRouterWithBloc extends ChangeNotifier {
  /// Creates a [MarryGoRouterWithBloc].
  ///
  /// Every time the [bloc.stream] receives an event the [GoRouter] will refresh its
  /// current route.
  MarryGoRouterWithBloc(Bloc bloc) {
    notifyListeners();
    _subscription = bloc.stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
