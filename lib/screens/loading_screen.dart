import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'countdown_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GameState>(
      stream: GameService().changes,
      initialData: GameService().state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.phase == GamePhase.countdown ||
            state.phase == GamePhase.flashing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CountdownScreen()),
              );
          });
        }
        return Scaffold(
          backgroundColor: const Color(0xFF101B20),
          body: Center(
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
                    GameService().leaveQueue();
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
