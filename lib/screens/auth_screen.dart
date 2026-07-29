import 'package:flutter/material.dart';
import 'login_box.dart';
import 'signup_box.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Toggle state: true = Login, false = SignUp
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent overflow issues when keyboard opens
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Permanent Fullscreen Background Image
          // This never rebuilds or reloads when toggling login/signup!
          Positioned.fill(
            child: Image.asset('images/background.png', fit: BoxFit.cover),
          ),

          // 2. Centered Dynamic Auth Box
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              // AnimatedSwitcher gives a smooth fade transition between screens
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLogin
                    ? LoginBox(
                        key: const ValueKey('login'),
                        onSwitchToSignUp: _toggleAuthMode,
                      )
                    : SignUpBox(
                        key: const ValueKey('signup'),
                        onSwitchToLogin: _toggleAuthMode,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
