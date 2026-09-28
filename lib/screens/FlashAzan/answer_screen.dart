import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';
// Note: Assuming GoogleFonts is imported if you want to use it for fallbacks,
// but using standard TextStyle for 'Iosevka Charon Mono' as requested.

class AnswerInputView extends StatefulWidget {
  const AnswerInputView({super.key});

  @override
  State<AnswerInputView> createState() => _AnswerInputViewState();
}

class _AnswerInputViewState extends State<AnswerInputView> {
  final _controller = TextEditingController();
  Timer? _timer;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final state = context.read<GameService>().state;
      if (!mounted) return;
      final left =
          state.roundDurationSec * 1000 -
          (DateTime.now().millisecondsSinceEpoch - state.serverTimestamp);
      if (left <= 0) {
        _submit();
      } else {
        setState(() {});
      }
    });
  }

  void _submit() {
    if (_submitted) return;
    _submitted = true;
    context.read<GameService>().submitAnswer(
      int.tryParse(_controller.text.trim()) ?? 0,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameService>().state;
    final left =
        ((state.roundDurationSec * 1000 -
                    (DateTime.now().millisecondsSinceEpoch -
                        state.serverTimestamp)) /
                1000)
            .ceil()
            .clamp(0, state.roundDurationSec);

    // Format timer display string (e.g. 00:10)
    final formattedTimer = '00:${left.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: AspectRatio(
              // Using the 773x909 ratio from your Figma specs
              aspectRatio: 773 / 909,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161111),
                  // Proportional corner radius based on your 76px spec
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: const Color(
                      0xFF00A3FF,
                    ), // Neon blue border from the image
                    width: 3.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ANSWER Title
                    const Text(
                      'ANSWER',
                      style: TextStyle(
                        fontFamily:
                            'Iosevka Charon Mono', // Your specified font
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Box (Proportional to 477x103)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth * (477 / 773),
                          height: constraints.maxWidth * (103 / 773),
                          decoration: BoxDecoration(
                            color: const Color(0xFF261D1D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _controller,
                            enabled: !_submitted,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 24,
                              fontFamily: 'Iosevka Charon Mono',
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: '0.0',
                              hintStyle: TextStyle(
                                color: Colors.white30,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Timer Box (Proportional styling)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF261D1D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formattedTimer,
                        style: const TextStyle(
                          color: Color(0xFF81F1FB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Added Custom Submit Button
                    InkWell(
                      onTap: _submitted ? null : _submit,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _submitted
                              ? Colors.grey.withOpacity(0.1)
                              : const Color(0xFF6EDDFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _submitted
                                ? Colors.grey.withOpacity(0.5)
                                : const Color(0xFF6EDDFF),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _submitted ? 'WAITING...' : 'SUBMIT',
                          style: TextStyle(
                            fontFamily: 'Iosevka Charon Mono',
                            color: _submitted
                                ? Colors.grey
                                : const Color(0xFF6EDDFF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
