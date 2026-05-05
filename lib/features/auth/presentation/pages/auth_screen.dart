import 'package:flutter/material.dart';

import 'package:smart_campus/features/auth/presentation/pages/login_page.dart';
import 'package:smart_campus/features/auth/presentation/pages/sign_up_page.dart';

/// Owns the Sign In ↔ Sign Up toggle as local state. Swapping mode is a
/// `setState`, NOT a `Navigator.pushReplacement` — pushing would unmount
/// the AuthGate that listens for `Authenticated` transitions, leaving
/// nothing to swap in the dashboard after a successful login or sign-up.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signUpMode = false;

  void _switchToSignUp() => setState(() => _signUpMode = true);
  void _switchToSignIn() => setState(() => _signUpMode = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _signUpMode
          ? SignUpPage(
              key: const ValueKey('signup'),
              onSwitchToSignIn: _switchToSignIn,
            )
          : LoginPage(
              key: const ValueKey('signin'),
              onSwitchToSignUp: _switchToSignUp,
            ),
    );
  }
}
