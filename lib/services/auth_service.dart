import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Shorthand reference to the Supabase Auth client
  final GoTrueClient _auth = Supabase.instance.client.auth;

  /// Returns the current active user, or null if logged out.
  User? get currentUser => _auth.currentUser;

  /// SIGN IN with Email and Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      // Supabase-specific auth errors (e.g., "Invalid login credentials")
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// SIGN UP with Email and Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
