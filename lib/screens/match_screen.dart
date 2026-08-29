import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_multiplayer/services/socket_service.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({Key? key}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final SocketService _socketService = SocketService();

  // ---------------------------------------------------------------------------
  // Game state
  // ---------------------------------------------------------------------------

  /// Current UI phase:
  /// waiting  → in matchmaking queue
  /// matched  → opponent found, countdown to first round
  /// display  → numbers are being shown
  /// input    → player can type their answer
  /// result   → round result is showing
  /// over     → game finished
  String _phase = 'waiting';

  int? _gameId;
  List<dynamic> _numbers = [];
  int _timerSeconds = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  Map<String, dynamic> _scores = {};
  int? _correctAnswer;
  String? _winner;

  final TextEditingController _answerController = TextEditingController();
  bool _answerSubmitted = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _socketService.joinQueue();
  }

  @override
  void dispose() {
    _socketService.leaveQueue();
    _socketService.clearGameListeners();
    _answerController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Socket event listeners
  // ---------------------------------------------------------------------------

  void _setupListeners() {
    _socketService.onMatchFound((data) {
      setState(() {
        _gameId = data['gameId'];
        _phase = 'matched';
      });
    });

    _socketService.onGameStart((data) {
      setState(() {
        _totalRounds = data['totalRounds'];
        _timerSeconds = (data['startsIn'] as num).toInt();
      });
    });

    _socketService.onRoundStart((data) {
      setState(() {
        _phase = 'display';
        _currentRound = data['round'];
        _numbers = List<dynamic>.from(data['numbers']);
        _timerSeconds = (data['timeLimit'] as num).toInt();
        _answerSubmitted = false;
        _answerController.clear();
      });
    });

    _socketService.onRoundResult((data) {
      setState(() {
        _phase = 'result';
        _correctAnswer = (data['correctAnswer'] as num).toInt();
        _scores = Map<String, dynamic>.from(data['scores']);
      });
    });

    _socketService.onGameOver((data) {
      setState(() {
        _phase = 'over';
        _scores = Map<String, dynamic>.from(data['scores']);
        _winner = data['winner'];
      });
    });

    _socketService.onOpponentLeft((data) {
      setState(() {
        _phase = 'over';
        _winner = data['winner'];
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _submitAnswer() {
    if (_answerSubmitted || _gameId == null) return;

    final text = _answerController.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == null) return;

    _socketService.submitAnswer(_gameId!, parsed, _currentRound); //check round
    setState(() {
      _answerSubmitted = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1080,
              height: 1920,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer Box
                  Container(
                    width: 185,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF342D2D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _formatTimer(_timerSeconds),
                      style: GoogleFonts.getFont(
                        'Intel One Mono',
                        color: const Color(0xFF81F1FB),
                        fontSize: 39,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Round indicator
                  if (_currentRound > 0)
                    Text(
                      'Round $_currentRound / $_totalRounds',
                      style: GoogleFonts.getFont(
                        'Intel One Mono',
                        color: Colors.white70,
                        fontSize: 28,
                      ),
                    ),

                  const SizedBox(height: 60),

                  // Player scores row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlayerBox('YOU', _getMyScore()),
                      const SizedBox(width: 120),
                      _buildPlayerBox('OPPONENT', _getOpponentScore()),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // Central content — changes based on phase
                  _buildCentralContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Central content per phase
  // ---------------------------------------------------------------------------

  Widget _buildCentralContent() {
    switch (_phase) {
      case 'waiting':
        return _buildCentralBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF6EDDFF)),
              const SizedBox(height: 40),
              Text(
                'Finding\nOpponent...',
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: const Color(0xFF6EDDFF),
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );

      case 'matched':
        return _buildCentralBox(
          child: Text(
            'Matched!\nGet Ready',
            textAlign: TextAlign.center,
            style: GoogleFonts.getFont(
              'Intel One Mono',
              color: const Color(0xFF6EDDFF),
              fontSize: 64,
              fontWeight: FontWeight.w300,
            ),
          ),
        );

      case 'display':
        // Show the numbers to memorise / add up
        final displayText = _numbers.join('  +  ');
        return _buildCentralBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Memorise!',
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: Colors.white54,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                displayText,
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: const Color(0xFF6EDDFF),
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );

      case 'input':
        return _buildCentralBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Sum',
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: Colors.white54,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _answerController,
                  enabled: !_answerSubmitted,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    'Intel One Mono',
                    color: const Color(0xFF6EDDFF),
                    fontSize: 64,
                  ),
                  decoration: InputDecoration(
                    hintText: '?',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 64),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF6EDDFF),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF81F1FB),
                        width: 3,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.white24,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _submitAnswer(),
                ),
              ),
              const SizedBox(height: 30),
              if (!_answerSubmitted)
                ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6EDDFF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.getFont(
                      'Intel One Mono',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  'Submitted ✓',
                  style: GoogleFonts.getFont(
                    'Intel One Mono',
                    color: const Color(0xFF6EDDFF),
                    fontSize: 36,
                  ),
                ),
            ],
          ),
        );

      case 'result':
        return _buildCentralBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Answer',
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: Colors.white54,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_correctAnswer ?? '?'}',
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: const Color(0xFF6EDDFF),
                  fontSize: 120,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );

      case 'over':
        final isWinner = _winner == _socketService.socket.id;
        final isDraw = _winner == null;
        return _buildCentralBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isDraw
                    ? 'Draw!'
                    : isWinner
                    ? 'You Win!'
                    : 'You Lose',
                style: GoogleFonts.getFont(
                  'Intel One Mono',
                  color: const Color(0xFF6EDDFF),
                  fontSize: 72,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EDDFF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.getFont(
                    'Intel One Mono',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildCentralBox({required Widget child}) {
    return Container(
      width: 623.5,
      height: 1210.5,
      decoration: BoxDecoration(
        color: const Color(0xFF342D2D),
        borderRadius: BorderRadius.circular(60),
      ),
      alignment: Alignment.center,
      child: Padding(padding: const EdgeInsets.all(40.0), child: child),
    );
  }

  Widget _buildPlayerBox(String label, int score) {
    return Container(
      width: 256,
      height: 196,
      decoration: BoxDecoration(
        color: const Color(0xFF342D2D),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.getFont(
              'Intel One Mono',
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: GoogleFonts.getFont(
              'Intel One Mono',
              color: const Color(0xFF6EDDFF),
              fontSize: 48,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _getMyScore() {
    final myId = _socketService.socket.id;
    if (myId == null || _scores.isEmpty) return 0;
    return (_scores[myId] as num?)?.toInt() ?? 0;
  }

  int _getOpponentScore() {
    final myId = _socketService.socket.id;
    if (myId == null || _scores.isEmpty) return 0;
    for (final entry in _scores.entries) {
      if (entry.key != myId) {
        return (entry.value as num).toInt();
      }
    }
    return 0;
  }
}
