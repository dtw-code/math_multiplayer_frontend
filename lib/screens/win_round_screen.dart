import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreComparisonScreen extends StatelessWidget {
  const ScoreComparisonScreen({Key? key}) : super(key: key);

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
            width: 320,
            height: 450, // Slightly taller to accommodate the taller bars
            decoration: BoxDecoration(
              color: const Color(0xFF0F2125), // Outermost box color
              borderRadius: BorderRadius.circular(
                76,
              ), // Kept consistent with previous designs
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centers the blocks vertically
              children: [
                // 'YOU' Block (Scaled dimensions: approx 106 x 274)
                _buildScoreBlock(
                  title: 'YOU',
                  score: '20',
                  blockWidth: 106,
                  blockHeight: 274,
                  numberColor: const Color(0xFF00C8B3),
                ),

                // 'BOT' Block (Scaled dimensions: approx 106 x 168)
                _buildScoreBlock(
                  title: 'BOT',
                  score: '10',
                  blockWidth: 106,
                  blockHeight: 168,
                  numberColor: const Color(0xFF261971),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the vertical score blocks
  Widget _buildScoreBlock({
    required String title,
    required String score,
    required double blockWidth,
    required double blockHeight,
    required Color numberColor,
  }) {
    return Container(
      width: blockWidth,
      height: blockHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF324B4F), // Background color of inner blocks
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
              color: numberColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
