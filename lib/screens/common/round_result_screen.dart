import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';

class RoundResultView extends StatefulWidget {
  const RoundResultView({super.key});

  @override
  State<RoundResultView> createState() => _RoundResultViewState();
}

class _RoundResultViewState extends State<RoundResultView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      final service = context.read<GameService>();
      if (service.state.hasPendingGameOver) {
        service.showPendingGameOver();
      } else if (service.state.hasPendingRound) {
        service.showPendingRound();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<GameService>().state.roundResult;

    return Center(
      child: result == null
          ? const CircularProgressIndicator(color: Color(0xFF6EDDFF))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF131D21,
                    ), // Dark slate/teal background matching the design
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SCORE',
                        style: const TextStyle(
                          fontFamily: 'Iosevka Charon Mono',
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Answer Info
                      Text(
                        'YOUR ANSWER: ${result.myAnswer ?? 'No answer'}',
                        style: const TextStyle(
                          fontFamily: 'Iosevka Charon Mono',
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CORRECT: ${result.correctAnswer}',
                        style: const TextStyle(
                          fontFamily: 'Iosevka Charon Mono',
                          color: Color(0xFF6EDDFF),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Score Cards Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _scoreCard(
                            label: 'YOU',
                            score: result.myScore,
                            valueColor: const Color(0xFF6EDDFF), // Neon Cyan
                          ),
                          const SizedBox(width: 24),
                          _scoreCard(
                            label: 'BOT',
                            score: result.opponentScore,
                            valueColor: const Color(0xFFcb30ff),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _scoreCard({
    required String label,
    required int score,
    required Color valueColor,
  }) {
    // Dynamic height calculation: Base height + (score * factor)
    // Capped at a sensible max height to prevent UI overflow
    final double cardHeight = (120.0 + (score * 15)).clamp(120.0, 300.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: 100,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF223238), // Lighter slate for the cards
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              color: Colors.white54,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: valueColor,
              shadows: [
                Shadow(color: valueColor.withOpacity(0.5), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
