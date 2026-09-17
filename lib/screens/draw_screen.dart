import 'package:flutter/material.dart';

class DrawScreen extends StatelessWidget {
  const DrawScreen({
    super.key,
    required this.myScore,
    required this.opponentScore,
  });
  final int myScore;
  final int opponentScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101B20),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DRAW',
              style: TextStyle(
                color: Color(0xFF81F1FB),
                fontSize: 48,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'YOU  $myScore   -   $opponentScore  OPPONENT',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
