/// All possible UI phases during a game session.
enum GamePhase {
  idle,
  waiting,
  matched,
  countdown,
  flashing,
  answering,
  roundResult,
  gameOver,
}

/// Holds the full client-side state of an active game.
///
/// [GameService] updates this object as socket events arrive.
/// Screens read from it to render the UI.
class RoundResult {
  const RoundResult({
    required this.round,
    required this.myAnswer,
    required this.correctAnswer,
    required this.myRoundScore,
    required this.opponentRoundScore,
    required this.myScore,
    required this.opponentScore,
    required this.endOfGame,
  });
  final int round;
  final int? myAnswer;
  final int correctAnswer;
  final int myRoundScore;
  final int opponentRoundScore;
  final int myScore;
  final int opponentScore;
  final bool endOfGame;
}

class GameState {
  GamePhase phase = GamePhase.idle;
  int? gameId;
  String? playerId;
  String? opponentId;
  int totalRounds = 3;
  int countdownSeconds = 5;
  int currentRound = 0;
  List<int> numbers = <int>[];
  int serverTimestamp = 0;
  int roundDurationSec = 12;
  int myScore = 0;
  int opponentScore = 0;
  String? winnerId;
  RoundResult? roundResult;
  bool hasPendingRound = false;
  bool hasPendingGameOver = false;
  Map<String, dynamic>? pendingRound;
  Map<String, dynamic>? pendingGameOver;
  String? errorMessage;

  void reset() {
    phase = GamePhase.idle;
    gameId = null;
    playerId = null;
    opponentId = null;
    totalRounds = 3;
    phase = GamePhase.idle;
    countdownSeconds = 5;
    currentRound = 0;
    numbers = <int>[];
    serverTimestamp = 0;
    roundDurationSec = 12;
    myScore = 0;
    opponentScore = 0;
    roundResult = null;
    winnerId = null;
    hasPendingRound = false;
    hasPendingGameOver = false;
    pendingRound = null;
    pendingGameOver = null;
    errorMessage = null;
  }
}
