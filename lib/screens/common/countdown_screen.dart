import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';

class CountdownView extends StatefulWidget {
  final int? countdownSeconds;
  final VoidCallback? onCancel;

  const CountdownView({super.key, this.countdownSeconds, this.onCancel});

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  Timer? _timer;
  late final int _localStartTime;

  @override
  void initState() {
    super.initState();
    _localStartTime = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
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
    final int countdownSec =
        widget.countdownSeconds ??
        context.watch<GameService>().state.countdownSeconds;
    final totalDurationMs = countdownSec * 1000;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - _localStartTime;
    final remainingMs = (totalDurationMs - elapsedMs).clamp(0, totalDurationMs);
    final remainingSec = (remainingMs / 1000).ceil();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MATCH STARTING',
            style: TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              color: Colors.white70,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            remainingSec == 1 ? 'GO' : '${remainingSec - 1}',
            style: const TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              color: Color(0xFF81F1FB),
              fontSize: 96,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 36),
          TextButton(
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                context.read<GameService>().leaveQueue();
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'Iosevka Charon Mono',
                letterSpacing: 1.5,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
