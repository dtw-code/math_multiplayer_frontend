import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';

class CountdownView extends StatefulWidget {
  const CountdownView({super.key});

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
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
    final state = context.watch<GameService>().state;
    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - state.serverTimestamp) ~/ 1000;
    final remaining = (state.countdownSeconds - elapsed).clamp(
      0,
      state.countdownSeconds,
    );
    return Center(
      child: Text(
        remaining == 0 ? 'GO' : '$remaining',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 96,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
