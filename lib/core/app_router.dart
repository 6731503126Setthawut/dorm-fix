
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/complete_profile_screen.dart';
import '../features/requests/screens/request_list_screen.dart';
import '../features/requests/screens/create_request_screen.dart';
import '../features/requests/screens/request_detail_screen.dart';
import '../features/admin/screens/admin_screen.dart';

class RouteNames {
  static const login = '/login';
  static const register = '/register';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const create = '/create';
  static const detail = '/detail/:id';
  static const admin = '/admin';
  static String detailPath(String id) => '/detail/$id';
}

class AppRouter {

  static final router = GoRouter(
    
    initialLocation: RouteNames.login,
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      if (!auth.isInitialized) return null;
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final onAuth = loc == RouteNames.login || loc == RouteNames.register;
      if (!loggedIn && !onAuth) return RouteNames.login;
      if (loggedIn && onAuth) {
        if (auth.needsProfile) return RouteNames.completeProfile;
        return RouteNames.home;
      }
      if (loggedIn && auth.needsProfile && loc != RouteNames.completeProfile) return RouteNames.completeProfile;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: RouteNames.completeProfile, builder: (_, __) => const CompleteProfileScreen()),
      GoRoute(path: RouteNames.home, builder: (_, __) => const RequestListScreen()),
      GoRoute(path: RouteNames.create, builder: (_, __) => const CreateRequestScreen()),
      GoRoute(path: RouteNames.detail, builder: (_, state) => RequestDetailScreen(requestId: state.pathParameters['id']!)),
      GoRoute(path: RouteNames.admin, builder: (_, __) => const AdminScreen()),
    ],
  );
}