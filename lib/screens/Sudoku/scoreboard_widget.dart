import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreboardWidget extends StatelessWidget {
  final String title;
  final String score;

  const ScoreboardWidget({Key? key, required this.title, required this.score})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Scaled from 223
      height: 56, // Scaled from 112
      decoration: BoxDecoration(
        color: const Color(0xFF262222),
        border: Border.all(
          color: const Color(0xFF4033B8),
          width: 2.5, // Scaled from 5
        ),
        borderRadius: BorderRadius.circular(30), // Pill shape
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 12),
          ),
          Text(
            score,
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
