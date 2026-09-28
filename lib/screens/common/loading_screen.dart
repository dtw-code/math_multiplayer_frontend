import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/flash_game_service.dart';
import 'package:provider/provider.dart';

class WaitingView extends StatelessWidget {
  final bool? isMatched;
  final VoidCallback? onCancel;

  const WaitingView({super.key, this.isMatched, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bool matched;
    if (isMatched != null) {
      matched = isMatched!;
    } else {
      matched = context.watch<GameService>().state.phase == GamePhase.matched;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF81F1FB)),
          const SizedBox(height: 24),
          Text(
            matched ? 'Opponent found' : 'Finding Opponent...',
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              } else {
                context.read<GameService>().leaveQueue();
                Navigator.pop(context);
              }
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
