import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_router.dart';
import 'features/requests/providers/request_provider.dart';
// ignore_for_file: deprecated_member_use

void main() {
  runApp(const DormFixApp());
}

class DormFixApp extends StatelessWidget {
  const DormFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: MaterialApp.router(
        title: 'DormFix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF202124);
  static const Color outline = Color(0xFFDADCE0);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: onSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: outline),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}