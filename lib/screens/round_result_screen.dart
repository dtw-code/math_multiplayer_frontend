import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'countdown_screen.dart';
import 'draw_screen.dart';
import 'defeat_game_screen.dart';
import 'victory_game_screen.dart';

class RoundResultScreen extends StatefulWidget {
  const RoundResultScreen({super.key});
  @override
  State<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends State<RoundResultScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _continue);
  }

  void _continue() {
    if (!mounted || _navigated) return;
    final service = GameService();
    if (service.state.hasPendingGameOver) service.showPendingGameOver();
    if (service.state.phase == GamePhase.gameOver) {
      _navigated = true;
      final state = service.state;
      final page = state.winnerId == null
          ? DrawScreen(
              myScore: state.myScore,
              opponentScore: state.opponentScore,
            )
          : state.winnerId == state.playerId
          ? VictoryScreen(
              myScore: state.myScore,
              opponentScore: state.opponentScore,
            )
          : DefeatScreen(
              myScore: state.myScore,
              opponentScore: state.opponentScore,
            );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    } else if (service.state.hasPendingRound) {
      service.showPendingRound();
      _navigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CountdownScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = GameService().state.roundResult;
    return Scaffold(
      backgroundColor: const Color(0xFF101B20),
      body: Center(
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
