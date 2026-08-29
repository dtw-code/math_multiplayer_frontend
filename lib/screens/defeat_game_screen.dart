import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DefeatScreen extends StatelessWidget {
  const DefeatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // The background is an image from 'images/background.png'
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 320, // Re-using width and height specs
            height: 380,
            decoration: BoxDecoration(
              color: const Color(0xFF101B20), // Dark background from image
              // The outer box has a corner radius of 76 px
              borderRadius: BorderRadius.circular(76),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 'defeat' is colored with CC3F42 (hex)
                Text(
                  'DEFEAT',
                  style: GoogleFonts.shareTechMono(
                    color: const Color(0xFFCC3F42),
                    fontSize: 42,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),

                // Score Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreCard('YOU', '20'),
                    _buildScoreCard('BOT', '10'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, String score) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF334A4D), // Inner box color from image
        // the inner small box has a radius of around 30 px
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Labels use standard dark color for readability
          Text(
            title,
            style: GoogleFonts.shareTechMono(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // color of number is 651C1D
          Text(
            score,
            style: GoogleFonts.shareTechMono(
              color: const Color(0xFF651C1D),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
