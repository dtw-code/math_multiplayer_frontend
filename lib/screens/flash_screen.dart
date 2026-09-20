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
  late int _secondsLeft;
  @override
  void initState() {
    super.initState();
    _secondsLeft = AppConfig.flashDurationSec; // e.g. 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        context.read<GameService>().startAnswering();
      } else {
        setState(() {
          _secondsLeft--;
        });
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
    // Calculate which number to show based on elapsed seconds
    final elapsedSec = AppConfig.flashDurationSec - _secondsLeft;
    final totalNumbers = state.numbers.isEmpty ? 1 : state.numbers.length;
    final secPerNumber = AppConfig.flashDurationSec / totalNumbers;
    final index = (elapsedSec / secPerNumber).floor().clamp(
      0,
      totalNumbers - 1,
    );

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$_secondsLeft',
              style: const TextStyle(color: Color(0xFF81F1FB), fontSize: 28),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                state.numbers.isEmpty ? '...' : '${state.numbers[index]}',
                style: const TextStyle(
                  color: Colors.red,
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
