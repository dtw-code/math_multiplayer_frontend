/// AuthScreen (Login/Signup) if signed out, or HomeScreen if signed in.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:math_multiplayer/screens/homescreen.dart';
import 'package:math_multiplayer/screens/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Listen to real-time auth changes from Supabase
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading spinner while checking initial session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF161111),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if a valid session exists
        final session = snapshot.data?.session;

        if (session != null) {
          return const HomePage(); // Redirect to home when logged in
        } else {
          return const AuthScreen(); // Show our custom login/signup wrapper
        }
      },
    );
  }
}
