import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/requests/screens/request_list_screen.dart';
import '../features/requests/screens/create_request_screen.dart';
import '../features/requests/screens/request_detail_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';

abstract class RouteNames {
  static const login = '/';
  static const register = '/register';
  static const home = '/home';
  static const create = '/create';
  static const detail = '/detail/:id';
  static const admin = '/admin';
  static String detailPath(String id) => '/detail/$id';
}

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final loggedIn = auth.isAuthenticated;
      final onAuth = state.matchedLocation == RouteNames.login || state.matchedLocation == RouteNames.register;
      if (!loggedIn && !onAuth) return RouteNames.login;
      if (loggedIn && onAuth) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, name: 'login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: RouteNames.register, name: 'register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: RouteNames.home, name: 'home', builder: (c, s) => const RequestListScreen()),
      GoRoute(path: RouteNames.create, name: 'create', builder: (c, s) => const CreateRequestScreen()),
      GoRoute(path: RouteNames.detail, name: 'detail', builder: (c, s) => RequestDetailScreen(requestId: s.pathParameters['id']!)),
      GoRoute(path: RouteNames.admin, name: 'admin', builder: (c, s) => const AdminDashboardScreen()),
    ],
  );
}