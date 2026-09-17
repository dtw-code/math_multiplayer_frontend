import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/config/app_config.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'answer_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});
  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  Timer? _timer;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final state = GameService().state;
      if (!mounted || state.phase != GamePhase.flashing) return;
      setState(
        () => _elapsedMs =
            DateTime.now().millisecondsSinceEpoch - state.serverTimestamp,
      );
      if (_elapsedMs >= AppConfig.flashDurationSec * 1000) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AnswerScreen()),
        );
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
    final state = GameService().state;
    final slotMs =
        AppConfig.flashDurationSec *
        1000 ~/
        (state.numbers.isEmpty ? 1 : state.numbers.length);
    final index = (_elapsedMs ~/ slotMs).clamp(0, state.numbers.length - 1);
    final remaining = ((state.roundDurationSec * 1000 - _elapsedMs) / 1000)
        .ceil()
        .clamp(0, state.roundDurationSec);
    return Scaffold(
      backgroundColor: const Color(0xFF101B20),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '$remaining',
                style: const TextStyle(color: Color(0xFF81F1FB), fontSize: 28),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  state.numbers.isEmpty ? '...' : '${state.numbers[index]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 88,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              'Round ${state.currentRound} / ${state.totalRounds}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
