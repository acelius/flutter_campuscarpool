import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/home_shell.dart';
import 'features/auth/login_page.dart';

class CampusCarpoolApp extends StatelessWidget {
  const CampusCarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Carpool',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A4EA2),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF5F8FC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F8FC),
          foregroundColor: Color(0xFF18324B),
          centerTitle: false,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE6F0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0A4EA2), width: 1.5),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Terjadi kesalahan autentikasi')),
          );
        }

        if (snapshot.data != null) {
          return const HomeShell();
        }

        return const LoginPage();
      },
    );
  }
}
