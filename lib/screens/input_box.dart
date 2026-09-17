import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({Key? key}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _answerController = TextEditingController(
    text: "0.0",
  );

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('images/background.png', fit: BoxFit.cover),

          // Main Content Area
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 477,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 48.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141010).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Header
                    Text(
                      'ANSWER',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 42,
                        color: Colors.white,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Input Box (477 x 103 target ratio scaled nicely within padding)
                    SizedBox(
                      height: 70,
                      child: TextField(
                        controller: _answerController,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inriaSans(
                          fontSize: 32,
                          color: const Color(0xFF8D8383),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF231C1C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Static Timer (220 x 85 target ratio scaled visually)
                    Container(
                      width: 160,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFF231C1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '00:50',
                        style: GoogleFonts.inriaSans(
                          fontSize: 22,
                          color: const Color(0xFF6BD0BD),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
