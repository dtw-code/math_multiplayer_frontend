/// All possible UI phases during a Sudoku multiplayer session.
enum SudokuGamePhase {
  idle,
  waiting,
  matched,
  countdown,
  playing,
  overtime,
  gameOver,
}

/// Holds the client-side state of an active Sudoku game session.
class SudokuGameState {
  SudokuGamePhase phase = SudokuGamePhase.idle;
  int? gameId;
  String? playerId;
  String? opponentId;
  int countdownSeconds = 5;
  int currentRound = 1;

  /// The raw puzzle payload from the server (contains puzzleId, index, grid).
  dynamic puzzle;

  /// The 6×6 grid the player is currently editing.
  /// Values: 1–6 for filled cells, 0 for empty.
  List<List<int>> grid = List.generate(6, (_) => List.filled(6, 0));

  /// Cells that came pre-filled from the server and cannot be edited.
  /// Stored as (row, col) pairs.
  Set<(int, int)> lockedCells = {};

  int currentPuzzleIndex = 0;
  int serverTimestamp = 0;
  int roundDurationSec = 60;
  int myScore = 0;
  int opponentScore = 0;
  bool isOvertime = false;
  String? winnerId;
  String? errorMessage;
  String? lastWrongReason;

  /// Parses the server puzzle data and populates [grid] and [lockedCells].
  ///
  /// Server sends puzzle via `getPublicData()` as:
  /// `{ puzzleId: string, index: int, grid: int[][] }`
  /// where empty cells are 0.
  void loadPuzzleFromServer(dynamic puzzleData) {
    puzzle = puzzleData;
    lockedCells = {};

    if (puzzleData is Map && puzzleData['grid'] != null) {
      final serverGrid = puzzleData['grid'] as List;
      grid = List.generate(6, (row) {
        final serverRow = (row < serverGrid.length)
            ? serverGrid[row] as List
            : [];
        return List.generate(6, (col) {
          final value = (col < serverRow.length)
              ? (serverRow[col] as num).toInt()
              : 0;
          if (value != 0) {
            lockedCells.add((row, col));
          }
          return value;
        });
      });
    } else {
      grid = List.generate(6, (_) => List.filled(6, 0));
    }
  }

  void reset() {
    phase = SudokuGamePhase.idle;
    gameId = null;
    playerId = null;
    opponentId = null;
    countdownSeconds = 5;
    currentRound = 1;
    puzzle = null;
    grid = List.generate(6, (_) => List.filled(6, 0));
    lockedCells = {};
    currentPuzzleIndex = 0;
    serverTimestamp = 0;
    roundDurationSec = 60;
    myScore = 0;
    opponentScore = 0;
    isOvertime = false;
    winnerId = null;
    errorMessage = null;
    lastWrongReason = null;
  }
}
