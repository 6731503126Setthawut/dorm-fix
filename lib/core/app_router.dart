import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/complete_profile_screen.dart';
import '../features/requests/screens/request_list_screen.dart';
import '../features/requests/screens/create_request_screen.dart';
import '../features/requests/screens/request_detail_screen.dart';
import '../features/admin/screens/admin_screen.dart';

class RouteNames {
  static const login = '/login';
  static const loading = '/loading';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const create = '/create';
  static const detail = '/detail/:id';
  static const admin = '/admin';
  static String detailPath(String id) => '/detail/$id';
}

GoRouter createRouter(AuthProvider auth) => GoRouter(
  initialLocation: RouteNames.loading,
  refreshListenable: auth,
  redirect: (context, state) {
    final loc = state.matchedLocation;

    // ยังโหลดไม่เสร็จ → อยู่หน้า loading
    if (!auth.isInitialized) {
      return loc == RouteNames.loading ? null : RouteNames.loading;
    }

    // โหลดเสร็จแล้ว ออกจาก loading
    if (loc == RouteNames.loading) {
      if (!auth.isAuthenticated) return RouteNames.login;
      if (auth.needsProfile) return RouteNames.completeProfile;
      return RouteNames.home;
    }

    // ไม่ได้ login
    if (!auth.isAuthenticated) {
      return loc == RouteNames.login ? null : RouteNames.login;
    }

    // login แล้ว อยู่หน้า login
    if (loc == RouteNames.login) {
      if (auth.needsProfile) return RouteNames.completeProfile;
      return RouteNames.home;
    }

    // ยังไม่กรอก profile
    if (auth.needsProfile && loc != RouteNames.completeProfile) {
      return RouteNames.completeProfile;
    }

    return null;
  },
  routes: [
    GoRoute(path: RouteNames.loading, builder: (_, __) => const _LoadingScreen()),
    GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
    GoRoute(path: RouteNames.completeProfile, builder: (_, __) => const CompleteProfileScreen()),
    GoRoute(path: RouteNames.home, builder: (_, __) => const RequestListScreen()),
    GoRoute(path: RouteNames.create, builder: (_, __) => const CreateRequestScreen()),
    GoRoute(path: RouteNames.detail, builder: (_, state) => RequestDetailScreen(requestId: state.pathParameters['id']!)),
    GoRoute(path: RouteNames.admin, builder: (_, __) => const AdminScreen()),
  ],
);

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Color(0xFF1A73E8),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('🏠', style: TextStyle(fontSize: 56)),
      SizedBox(height: 24),
      Text('DormFix', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
      SizedBox(height: 32),
      CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
    ])),
  );
}
