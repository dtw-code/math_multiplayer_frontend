import 'package:flutter/foundation.dart';
import 'package:math_multiplayer/models/sudoku_game_state.dart';
import 'package:math_multiplayer/services/socket_service.dart';

class SudokuGameService extends ChangeNotifier {
  static final SudokuGameService _instance = SudokuGameService._internal();
  factory SudokuGameService() => _instance;

  SudokuGameService._internal() {
    _socket = SocketService();
    _listen();
  }

  late final SocketService _socket;
  final SudokuGameState state = SudokuGameState();

  /// Joins the matchmaking queue for Sudoku
  void joinQueue() {
    state.reset();
    state.phase = SudokuGamePhase.waiting;
    notifyListeners();
    _socket.connect();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_socket.isConnected && state.phase == SudokuGamePhase.waiting) {
        _socket.joinQueue(gameType: 'sudoku');
      }
    });
  }

  /// Leaves the Sudoku queue
  void leaveQueue() {
    if (_socket.isConnected) {
      _socket.leaveQueue(gameType: 'sudoku');
    }
    state.reset();
    notifyListeners();
  }

  ///*** */ Submit a single cell entry for Sudoku (not required)
  void submitCell({required int row, required int col, required int value}) {
    if (state.gameId == null) return;
    _socket.submitCell(
      gameId: state.gameId!,
      round: state.currentRound,
      row: row,
      col: col,
      value: value,
    );
  }

  /// Submit the full solved puzzle grid (sends the 2D grid array).
  void submitPuzzle() {
    if (state.gameId == null) return;
    _socket.submitPuzzle(gameId: state.gameId!, puzzle: state.grid);
  }

  void _listen() {
    _socket.onMatchFound((data) {
      final payload = Map<String, dynamic>.from(data as Map);
      if (payload['gameType'] != null && payload['gameType'] != 'sudoku')
        return;
      state.playerId = _socket.socket.id;
      state.gameId = _int(payload['gameId']);
      state.opponentId = payload['player2']?.toString();
      state.phase = SudokuGamePhase.matched;
      notifyListeners();
    });

    _socket.onGameStart((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      state.countdownSeconds = _int(payload['startsIn']) ?? 5;
      state.serverTimestamp =
          _int(payload['timestamp']) ?? DateTime.now().millisecondsSinceEpoch;
      state.phase = SudokuGamePhase.countdown;
      notifyListeners();
    });

    _socket.onStartRound((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      state.loadPuzzleFromServer(payload['puzzle']);
      state.serverTimestamp =
          _int(payload['timestamp']) ?? DateTime.now().millisecondsSinceEpoch;
      state.roundDurationSec = _int(payload['duration']) ?? 60;
      state.isOvertime = false;
      state.phase = SudokuGamePhase.playing;
      notifyListeners();
    });

    _socket.onScoreUpdate((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      final scores = Map<String, dynamic>.from(payload['scores'] ?? {});
      final me = _socket.socket.id ?? '';
      state.myScore = _int(scores[me]) ?? state.myScore;
      state.opponentScore = _otherValue(scores, me);
      notifyListeners();
    });

    _socket.onPuzzleCompleted((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      state.myScore = _int(payload['score']) ?? state.myScore;
      state.currentPuzzleIndex =
          _int(payload['currentPuzzleIndex']) ?? state.currentPuzzleIndex + 1;
      if (payload['nextPuzzle'] != null) {
        state.loadPuzzleFromServer(payload['nextPuzzle']);
      }
      notifyListeners();
    });

    _socket.onPuzzleWrong((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      state.lastWrongReason = payload['reason']?.toString();
      if (payload['puzzle'] != null) {
        state.loadPuzzleFromServer(payload['puzzle']);
      }
      notifyListeners();
    });

    _socket.onOvertime((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = data != null
          ? Map<String, dynamic>.from(data as Map)
          : <String, dynamic>{};
      state.isOvertime = true;
      state.roundDurationSec = _int(payload['extraTime']) ?? 30;
      state.serverTimestamp = DateTime.now().millisecondsSinceEpoch;
      state.phase = SudokuGamePhase.overtime;
      notifyListeners();
    });

    _socket.onGameOver((data) {
      if (state.phase == SudokuGamePhase.idle) return;
      final payload = Map<String, dynamic>.from(data as Map);
      final scores = Map<String, dynamic>.from(payload['scores'] ?? {});
      final me = _socket.socket.id ?? '';
      state.myScore = _int(scores[me]) ?? state.myScore;
      state.opponentScore = _otherValue(scores, me);
      state.winnerId = payload['winner']?.toString();
      state.phase = SudokuGamePhase.gameOver;
      notifyListeners();
    });

    _socket.onOpponentDisconnected((_) {
      if (state.phase == SudokuGamePhase.idle) return;
      state.errorMessage = 'Your opponent disconnected.';
      state.phase = SudokuGamePhase.gameOver;
      notifyListeners();
    });
  }

  int _otherValue(Map<String, dynamic> values, String me) {
    final other = values.entries.firstWhere(
      (entry) => entry.key != me,
      orElse: () => const MapEntry('', 0),
    );
    return _int(other.value) ?? 0;
  }

  int? _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value');
}
