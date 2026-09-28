import 'package:flutter/material.dart';

class GameOverFallbackView extends StatelessWidget {
  final bool isDraw;
  final String? errorMessage;
  final int myScore;
  final int opponentScore;
  final VoidCallback? onHome;

  const GameOverFallbackView({
    super.key,
    required this.isDraw,
    this.errorMessage,
    required this.myScore,
    required this.opponentScore,
    this.onHome,
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
            onPressed:
                onHome ??
                () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('BACK TO HOME'),
          ),
        ],
      ),
    );
  }
}
