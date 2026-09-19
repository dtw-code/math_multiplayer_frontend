import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/config/app_config.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';

class FlashNumbersView extends StatefulWidget {
  const FlashNumbersView({super.key});

  @override
  State<FlashNumbersView> createState() => _FlashNumbersViewState();
}

class _FlashNumbersViewState extends State<FlashNumbersView> {
  Timer? _timer;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final service = context.read<GameService>();
      final state = service.state;
      if (!mounted || state.phase != GamePhase.flashing) return;
      final elapsed =
          DateTime.now().millisecondsSinceEpoch - state.serverTimestamp;
      if (elapsed >= AppConfig.flashDurationSec * 1000) {
        service.startAnswering();
      } else {
        setState(() => _elapsedMs = elapsed);
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
    final state = context.watch<GameService>().state;
    final slotMs =
        AppConfig.flashDurationSec *
        1000 ~/
        (state.numbers.isEmpty ? 1 : state.numbers.length);
    final index = state.numbers.isEmpty
        ? 0
        : (_elapsedMs ~/ slotMs).clamp(0, state.numbers.length - 1);
    final remaining = ((state.roundDurationSec * 1000 - _elapsedMs) / 1000)
        .ceil()
        .clamp(0, state.roundDurationSec);
    return SafeArea(
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
    );
  }
}
