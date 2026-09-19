import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/game_service.dart';
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
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ROUND ${result.round} RESULT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'YOUR ANSWER  ${result.myAnswer ?? 'No answer'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                Text(
                  'CORRECT  ${result.correctAnswer}',
                  style: const TextStyle(
                    color: Color(0xFF81F1FB),
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _scoreBar('YOU', result.myScore, const Color(0xFF00C8B3)),
                    const SizedBox(width: 20),
                    _scoreBar(
                      'OPPONENT',
                      result.opponentScore,
                      const Color(0xFFCC3F42),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _scoreBar(String label, int score, Color color) => Column(
    children: [
      Container(
        width: 90,
        height: 70.0 + score * 18,
        color: color,
        alignment: Alignment.center,
        child: Text(
          '$score',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ],
  );
}
