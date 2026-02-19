import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/requests/screens/request_list_screen.dart';
import '../features/requests/screens/create_request_screen.dart';
import '../features/requests/screens/request_detail_screen.dart';

abstract class RouteNames {
  static const login = '/';
  static const home = '/home';
  static const create = '/create';
  static const detail = '/detail/:id';

  static String detailPath(String id) => '/detail/$id';
}

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const RequestListScreen(),
      ),
      GoRoute(
        path: RouteNames.create,
        name: 'create',
        builder: (context, state) => const CreateRequestScreen(),
      ),
      GoRoute(
        path: RouteNames.detail,
        name: 'detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RequestDetailScreen(requestId: id);
        },
      ),
    ],
  );
}