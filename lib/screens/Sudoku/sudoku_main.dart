import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_multiplayer/services/sudoku_game_service.dart';
import 'package:math_multiplayer/models/sudoku_game_state.dart';
import 'package:math_multiplayer/utils/sudoku_validator.dart';
import 'timer_widget.dart';
import 'scoreboard_widget.dart';
import 'sudoku_board.dart';
import 'number_pad.dart';
import '../common/loading_screen.dart';
import '../common/countdown_screen.dart';
import '../common/victory_game_screen.dart';
import '../common/defeat_game_screen.dart';
import '../common/game_over_fallback.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({Key? key}) : super(key: key);

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  int? selectedRow;
  int? selectedCol;
  int? highlightedNumber;

  Timer? _gameTimer;
  late final SudokuGameService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<SudokuGameService>();
    _service.addListener(_onServiceUpdate);

    // Auto-join queue if idle
    if (_service.state.phase == SudokuGamePhase.idle) {
      _service.joinQueue();
    }

    _syncTimerForPhase(_service.state.phase);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _service.removeListener(_onServiceUpdate);
    if (_service.state.phase != SudokuGamePhase.gameOver &&
        _service.state.phase != SudokuGamePhase.idle) {
      _service.leaveQueue();
    }
    super.dispose();
  }

  /// Called whenever the SudokuGameService notifies listeners.
  void _onServiceUpdate() {
    if (!mounted) return;
    _syncTimerForPhase(_service.state.phase);
    setState(() {
      // State is read directly from _service.state — trigger a rebuild.
    });
  }

  /// Manages periodic ticker during active gameplay and overtime.
  void _syncTimerForPhase(SudokuGamePhase phase) {
    if (phase == SudokuGamePhase.playing || phase == SudokuGamePhase.overtime) {
      if (_gameTimer == null || !_gameTimer!.isActive) {
        _gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (mounted) setState(() {});
        });
      }
    } else {
      _gameTimer?.cancel();
      _gameTimer = null;
    }
  }

  /// The editable grid: reads directly from the service state.
  List<List<int>> get grid => _service.state.grid;

  /// Whether a cell is locked (original cell sent by server).
  bool _isLocked(int row, int col) =>
      _service.state.lockedCells.contains((row, col));

  void onCellTapped(int row, int col) {
    // Don't allow selecting locked (pre-filled) cells
    if (_isLocked(row, col)) return;

    setState(() {
      if (selectedRow == row && selectedCol == col) {
        // Double-tap: clear the cell
        grid[row][col] = 0;
        highlightedNumber = null;
      } else {
        selectedRow = row;
        selectedCol = col;
        final val = grid[row][col];
        highlightedNumber = (val != 0) ? val : null;
      }
    });
  }

  void onNumberTapped(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (_isLocked(selectedRow!, selectedCol!)) return;

    setState(() {
      grid[selectedRow!][selectedCol!] = number;
      highlightedNumber = number;
    });

    // Clear the wrong-answer feedback when the user edits
    _service.state.lastWrongReason = null;

    // Auto-submit when the grid is completely filled and valid
    _checkAndSubmit();
  }

  void _checkAndSubmit() {
    if (!SudokuValidator.isGridComplete(_gridAsNullable)) return;

    final conflicts = SudokuValidator.findConflicts(_gridAsNullable);
    if (conflicts.isNotEmpty) {
      // There are conflicts — don't submit, UI will highlight them
      setState(() {});
      return;
    }

    // Grid is complete & valid — send to server
    _service.submitPuzzle();
  }

  /// Convert `List<List<int>>` to `List<List<int?>>` for the validator
  /// (validator treats 0 as empty).
  List<List<int?>> get _gridAsNullable =>
      grid.map((row) => row.map((v) => v == 0 ? null : v).toList()).toList();

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = _service.state;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey<String>(
                '${state.phase.name}_${state.winnerId}_${state.isOvertime}',
              ),
              child: _buildPhaseView(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseView(BuildContext context, SudokuGameState state) {
    switch (state.phase) {
      case SudokuGamePhase.idle:
      case SudokuGamePhase.waiting:
        return WaitingView(
          isMatched: false,
          onCancel: () {
            _service.leaveQueue();
            Navigator.pop(context);
          },
        );

      case SudokuGamePhase.matched:
        return WaitingView(
          isMatched: true,
          onCancel: () {
            _service.leaveQueue();
            Navigator.pop(context);
          },
        );

      case SudokuGamePhase.countdown:
        return CountdownView(
          countdownSeconds: state.countdownSeconds,
          onCancel: () {
            _service.leaveQueue();
            Navigator.pop(context);
          },
        );

      case SudokuGamePhase.playing:
      case SudokuGamePhase.overtime:
        return _buildPlayingView(state);

      case SudokuGamePhase.gameOver:
        return _buildGameOverView(context, state);
    }
  }

  Widget _buildPlayingView(SudokuGameState state) {
    // Calculate remaining time
    final elapsed = state.serverTimestamp > 0
        ? (DateTime.now().millisecondsSinceEpoch - state.serverTimestamp) ~/
              1000
        : 0;
    final remaining = (state.roundDurationSec - elapsed).clamp(
      0,
      state.roundDurationSec,
    );

    // Convert grid for the board widget (board expects List<List<int?>>)
    final boardGrid = grid
        .map((row) => row.map((v) => v == 0 ? null : v).toList())
        .toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Top Timer
        TimerWidget(timeText: _formatTime(remaining)),
        const SizedBox(height: 20),

        // Scoreboards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScoreboardWidget(title: "you", score: state.myScore.toString()),
            ScoreboardWidget(
              title: "opp",
              score: state.opponentScore.toString(),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Outer Container (Game Area & Number Pad)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF161111),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Feedback banner
                  if (state.lastWrongReason != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Incorrect! Try again.',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Visibility(
                    visible:
                        state.isOvertime ||
                        state.phase == SudokuGamePhase.overtime,
                    child: const Text(
                      'Overtime..Be the first to solve',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Inria Sans',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Sudoku 6x6 Grid
                  SudokuBoard(
                    grid: boardGrid,
                    selectedRow: selectedRow,
                    selectedCol: selectedCol,
                    highlightedNumber: highlightedNumber,
                    conflictCells: SudokuValidator.findConflicts(_gridAsNullable),
                    onCellTapped: onCellTapped,
                  ),
                  // Number Input Pad
                  NumberPad(onNumberTapped: onNumberTapped),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGameOverView(BuildContext context, SudokuGameState state) {
    final disconnected = state.errorMessage != null;
    final draw = !disconnected && state.winnerId == null;
    final won = !draw && !disconnected && state.winnerId == state.playerId;

    if (won) {
      return VictoryView(
        myScore: state.myScore,
        opponentScore: state.opponentScore,
        opponentName: state.opponentId ?? 'OPPONENT',
        onHome: () {
          _service.leaveQueue();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    } else if (!draw && !disconnected) {
      return DefeatView(
        myScore: state.myScore,
        opponentScore: state.opponentScore,
        opponentName: state.opponentId ?? 'OPPONENT',
        onHome: () {
          _service.leaveQueue();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    } else {
      return GameOverFallbackView(
        isDraw: draw,
        errorMessage: state.errorMessage,
        myScore: state.myScore,
        opponentScore: state.opponentScore,
        onHome: () {
          _service.leaveQueue();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      );
    }
  }
}
