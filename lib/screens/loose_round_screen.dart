import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreResultScreen extends StatelessWidget {
  const ScoreResultScreen({Key? key}) : super(key: key);

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
            height: 450,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2125), // Outermost box color
              borderRadius: BorderRadius.circular(76),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 'YOU' Block - Score 5 (Shorter Block)
                _buildScoreBlock(
                  title: 'YOU',
                  score: '5',
                  blockWidth: 106,
                  blockHeight: 180, // Adjusted height for lower score
                  numberColor: const Color(0xFF5D1D0D), // 5D1D0D
                ),

                // 'BOT' Block - Score 10 (Taller Block)
                _buildScoreBlock(
                  title: 'BOT',
                  score: '10',
                  blockWidth: 106,
                  blockHeight: 274, // Adjusted height for higher score
                  numberColor: const Color(0xFFFF8D28), // FF8D28
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable helper widget for the vertical score blocks
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
