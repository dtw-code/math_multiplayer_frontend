import 'package:math_multiplayer/config/app_config.dart';
import 'package:math_multiplayer/models/game_state.dart';
import 'package:math_multiplayer/services/socket_service.dart';
import 'package:flutter/foundation.dart';

class GameService extends ChangeNotifier {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal() {
    _socket = SocketService();
    _listen();
  }

  late final SocketService _socket;
  final GameState state = GameState();

  void joinQueue() {
    state.reset();
    state.phase = GamePhase.waiting;
    notifyListeners();
    _socket.connect();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_socket.isConnected && state.phase == GamePhase.waiting) {
        _socket.joinQueue();
      }
    });
  }

  void leaveQueue() {
    if (_socket.isConnected) _socket.leaveQueue();
    state.reset();
    notifyListeners();
  }

  void submitAnswer(int answer) {
    if (state.gameId == null || state.phase != GamePhase.answering) return;
    _socket.submitAnswer(state.gameId!, answer, state.currentRound);
  }

  void startAnswering() {
    if (state.phase != GamePhase.flashing) return;
    state.phase = GamePhase.answering;
    notifyListeners();
  }

  void showPendingRound() {
    final next = state.pendingRound;
    if (next == null) return;
    state.pendingRound = null;
    state.hasPendingRound = false;
    _applyRound(next);
  }

  void showPendingGameOver() {
    final gameOver = state.pendingGameOver;
    if (gameOver == null) return;
    state.pendingGameOver = null;
    state.hasPendingGameOver = false;
    _applyGameOver(gameOver);
  }

  void _listen() {
    _socket.onMatchFound((data) {
      state.playerId = _socket.socket.id;
      state.gameId = _int(data['gameId']);
      state.opponentId = data['player2']?.toString();
      state.phase = GamePhase.matched;
      notifyListeners();
    });
    _socket.onGameStart((data) {
      state.totalRounds = _int(data['totalRounds']) ?? 3;
      state.countdownSeconds = _int(data['startsIn']) ?? 5;
      state.serverTimestamp =
          _int(data['timestamp']) ?? DateTime.now().millisecondsSinceEpoch;
      state.phase = GamePhase.countdown;
      notifyListeners();
    });

    _socket.onStartRound((data) {
      final payload = Map<String, dynamic>.from(data as Map);
      _applyRound(
        payload,
      ); // Immediately start the round when the server says so!
    });

    _socket.onRoundResult((data) {
      final payload = Map<String, dynamic>.from(data as Map);
      final answers = Map<String, dynamic>.from(payload['answers'] ?? {});
      final correctAnswers = Map<String, dynamic>.from(
        payload['correctAnswers'] ?? {},
      );
      final roundScores = Map<String, dynamic>.from(
        payload['roundScores'] ?? {},
      );
      final scores = Map<String, dynamic>.from(payload['scores'] ?? {});
      final me = _socket.socket.id ?? '';
      state.roundResult = RoundResult(
        round: _int(payload['round']) ?? state.currentRound,
        myAnswer: _int(answers[me]),
        correctAnswer: _int(correctAnswers[me]) ?? 0,
        myRoundScore: _int(roundScores[me]) ?? 0,
        opponentRoundScore: _otherValue(roundScores, me),
        myScore: _int(scores[me]) ?? 0,
        opponentScore: _otherValue(scores, me),
        endOfGame: payload['endOfGame'] == true,
      );
      state.myScore = state.roundResult!.myScore;
      state.opponentScore = state.roundResult!.opponentScore;
      state.phase = GamePhase.roundResult;
      notifyListeners();
    });

    _socket.onGameOver((data) {
      final payload = Map<String, dynamic>.from(data as Map);
      if (state.phase == GamePhase.roundResult) {
        state.pendingGameOver = payload;
        state.hasPendingGameOver = true;
      } else {
        _applyGameOver(payload);
      }
      notifyListeners();
    });

    _socket.onOpponentDisconnected((_) {
      state.errorMessage = 'Your opponent disconnected.';
      state.phase = GamePhase.gameOver;
      notifyListeners();
    });
  }

  void _applyRound(Map<String, dynamic> data) {
    state.currentRound = _int(data['round']) ?? state.currentRound + 1;
    state.numbers = (data['numbers'] as List? ?? [])
        .map((value) => _int(value) ?? 0)
        .toList();
    state.serverTimestamp =
        _int(data['timestamp']) ?? DateTime.now().millisecondsSinceEpoch;
    state.roundDurationSec =
        _int(data['duration']) ?? AppConfig.roundDurationSec;
    state.phase = GamePhase.flashing;
    state.roundResult = null;
    notifyListeners();
  }

  void _applyGameOver(Map<String, dynamic> data) {
    final scores = Map<String, dynamic>.from(data['scores'] ?? {});
    final me = _socket.socket.id ?? '';
    state.myScore = _int(scores[me]) ?? state.myScore;
    state.opponentScore = _otherValue(scores, me);
    state.winnerId = data['winner']?.toString();
    state.phase = GamePhase.gameOver;
    notifyListeners();
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
