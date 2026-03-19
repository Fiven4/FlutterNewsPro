import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/auth_controller.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Новостная лента',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F172A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: AnimatedBuilder(
        animation: authController,
        builder: (context, child) {
          if (!authController.isInitialized) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))),
            );
          }
          if (authController.currentUser == null) {
            return const LoginScreen();
          }
          return const MainScreen();
        },
      ),
    );
  }
}