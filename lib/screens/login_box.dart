import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class LoginBox extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;

  const LoginBox({super.key, required this.onSwitchToSignUp});

  @override
  State<LoginBox> createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _onProceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // NOTE: You don't need to manually navigate here!
      // The StreamBuilder in AuthGate will automatically detect the
      // session change and swap the screen to HomeScreen.
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
              'LOGIN',
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 3.0,
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
              onTap: widget.onSwitchToSignUp,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'SignUp',
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
