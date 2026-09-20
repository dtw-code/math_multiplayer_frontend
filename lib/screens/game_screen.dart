import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';

import 'answer_screen.dart';
import 'countdown_screen.dart';
import 'defeat_game_screen.dart'; // Import your custom Defeat view file
import 'flash_screen.dart';
import 'loading_screen.dart';
import 'round_result_screen.dart';
import 'victory_game_screen.dart'; // Import your custom Victory view file

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch gameService to ensure rebuilds when phase or game results update
    final gameService = context.watch<GameService>();
    final phase = gameService.state.phase;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E), // Dark cosmic fallback color
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Persistent background image (Never reloads/rebuilds)
          const BackgroundSpaceContainer(),

          // 2. Dynamic content overlay on top of the image
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey<String>(
                  '${phase.name}_${gameService.state.winnerId}',
                ),
                child: _viewForPhase(context, gameService.state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewForPhase(BuildContext context, GameState state) {
    switch (state.phase) {
      case GamePhase.waiting:
      case GamePhase.matched:
        return const WaitingView();
      case GamePhase.countdown:
        return const CountdownView();
      case GamePhase.flashing:
        return const FlashNumbersView();
      case GamePhase.answering:
        return const AnswerInputView();
      case GamePhase.roundResult:
        return const RoundResultView();
      case GamePhase.gameOver:
        return _viewForGameOver(state);
      case GamePhase.idle:
        return const WaitingView();
    }
  }

  Widget _viewForGameOver(GameState state) {
    final disconnected = state.errorMessage != null;
    final draw = !disconnected && state.winnerId == null;
    final won = !draw && !disconnected && state.winnerId == state.playerId;

    if (won) {
      return const VictoryView();
    } else if (!draw && !disconnected) {
      return const DefeatView();
    } else {
      // Fallback screen for Draw or Disconnection states
      return GameOverFallbackView(
        isDraw: draw,
        errorMessage: state.errorMessage,
        myScore: state.myScore,
        opponentScore: state.opponentScore,
      );
    }
  }
}

/// Constant background container
class BackgroundSpaceContainer extends StatelessWidget {
  const BackgroundSpaceContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Fallback view for Draw / Disconnected scenarios
class GameOverFallbackView extends StatelessWidget {
  final bool isDraw;
  final String? errorMessage;
  final int myScore;
  final int opponentScore;

  const GameOverFallbackView({
    super.key,
    required this.isDraw,
    this.errorMessage,
    required this.myScore,
    required this.opponentScore,
  });

  @override
  Widget build(BuildContext context) {
    final title = isDraw ? 'DRAW' : 'DISCONNECTED';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              color: Color(0xFF81F1FB),
              fontSize: 42,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Text(errorMessage!, style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 32),
          Text(
            'YOU  $myScore   -   $opponentScore  OPPONENT',
            style: const TextStyle(
              fontFamily: 'Iosevka Charon Mono',
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO HOME'),
          ),
        ],
      ),
    );
  }
}
