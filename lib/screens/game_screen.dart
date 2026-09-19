import 'package:flutter/material.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/game_service.dart';
import 'package:provider/provider.dart';
import 'answer_screen.dart';
import 'countdown_screen.dart';
import 'flash_screen.dart';
import 'loading_screen.dart';
import 'round_result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = context.watch<GameService>();
    return Scaffold(
      backgroundColor: const Color(0xFF101B20),
      body: _viewForPhase(gameService.state.phase),
    );
  }

  Widget _viewForPhase(GamePhase phase) {
    switch (phase) {
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
        return const GameOverView();
      case GamePhase.idle:
        return const WaitingView();
    }
  }
}

class GameOverView extends StatelessWidget {
  const GameOverView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameService>().state;
    final disconnected = state.errorMessage != null;
    final draw = !disconnected && state.winnerId == null;
    final won = !draw && !disconnected && state.winnerId == state.playerId;
    final title = disconnected
        ? 'DISCONNECTED'
        : draw
        ? 'DRAW'
        : won
        ? 'VICTORY'
        : 'DEFEAT';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF81F1FB),
              fontSize: 42,
              letterSpacing: 2,
            ),
          ),
          if (disconnected) ...[
            const SizedBox(height: 20),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'YOU  ${state.myScore}   -   ${state.opponentScore}  OPPONENT',
            style: const TextStyle(color: Colors.white, fontSize: 18),
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
