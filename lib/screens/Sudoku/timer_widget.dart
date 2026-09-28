import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerWidget extends StatelessWidget {
  final String timeText;

  const TimerWidget({Key? key, required this.timeText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Scaled down from 220
      height: 42, // Scaled down from 85
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2B1F1F),
        border: Border.all(
          color: const Color(0xFF45E0E5),
          width: 1.5, // Scaled down from 3
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        timeText,
        style: GoogleFonts.spaceMono(
          color: const Color(0xFF81F1FB),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
