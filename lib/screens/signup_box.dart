import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class SignUpBox extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const SignUpBox({super.key, required this.onSwitchToLogin});

  @override
  State<SignUpBox> createState() => _SignUpBoxState();
}

class _SignUpBoxState extends State<SignUpBox> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _onProceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      // Note: If you have "Confirm Email" enabled in Supabase dashboard,
      // notify user to check their email inbox.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Logging you in...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (errorMessage) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 48.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161111),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SignUp',
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 36),
            CustomTextField(
              hintText: 'email',
              controller: _emailController,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'password',
              isPassword: true,
              controller: _passwordController,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Confirm Password',
              isPassword: true,
              controller: _confirmPasswordController,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              height: 48,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ElevatedButton(
                      onPressed: _onProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E2330),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(94),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Proceed',
                        style: GoogleFonts.inriaSans(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onSwitchToLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Login',
                  style: GoogleFonts.inriaSans(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
