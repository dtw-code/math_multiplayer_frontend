import 'package:flutter_test/flutter_test.dart';
import 'package:math_multiplayer/models/game_state.dart';

void main() {
  test('game state resets to idle defaults', () {
    final state = GameState()
      ..phase = GamePhase.answering
      ..gameId = 7
      ..currentRound = 2
      ..myScore = 1;

    state.reset();

    expect(state.phase, GamePhase.idle);
    expect(state.gameId, isNull);
    expect(state.currentRound, 0);
    expect(state.myScore, 0);
  });
}
