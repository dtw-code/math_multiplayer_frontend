import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'flash_screen.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameState>(
      stream: GameService().changes,
      initialData: GameService().state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.phase == GamePhase.flashing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FlashScreen()),
              );
          });
        }
        final elapsed =
            (DateTime.now().millisecondsSinceEpoch - state.serverTimestamp) ~/
            1000;
        final remaining = (state.countdownSeconds - elapsed).clamp(
          0,
          state.countdownSeconds,
        );
        return Scaffold(
          backgroundColor: const Color(0xFF101B20),
          body: Center(
            child: Text(
              remaining == 0 ? 'GO' : '$remaining',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
