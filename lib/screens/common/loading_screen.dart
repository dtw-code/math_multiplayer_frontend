import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';

class WaitingView extends StatelessWidget {
  const WaitingView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameService>().state;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF81F1FB)),
          const SizedBox(height: 24),
          Text(
            state.phase == GamePhase.matched
                ? 'Opponent found'
                : 'Finding Opponent...',
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.read<GameService>().leaveQueue();
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
