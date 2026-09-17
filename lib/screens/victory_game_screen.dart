import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({
    super.key,
    required this.myScore,
    required this.opponentScore,
  });
  final int myScore;
  final int opponentScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Set the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 320, // Adjust width to fit your design needs
            height: 380,
            decoration: BoxDecoration(
              color: const Color(
                0xFF101B20,
              ), // Dark background matching the image
              borderRadius: BorderRadius.circular(76),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // VICTORY Text
                Text(
                  'VICTORY',
                  style: GoogleFonts.shareTechMono(
                    color: const Color(0xFF5390DF),
                    fontSize: 42,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),

                // Score Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreCard(title: 'YOU', score: '$myScore'),
                    _buildScoreCard(title: 'OPPONENT', score: '$opponentScore'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('BACK TO HOME'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for the inner score boxes
  Widget _buildScoreCard({required String title, required String score}) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF334A4D), // Inner box color from the image
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.shareTechMono(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score,
            style: GoogleFonts.shareTechMono(
              color: const Color(0xFF201971),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
