import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberTapped;

  const NumberPad({Key? key, required this.onNumberTapped}) : super(key: key);

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () => onNumberTapped(number),
      child: Container(
        width: 45,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xFF45E0E5), width: 2.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          number.toString(),
          style: GoogleFonts.inriaSans(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton(1),
            const SizedBox(width: 15),
            _buildNumberButton(2),
            const SizedBox(width: 15),
            _buildNumberButton(3),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton(4),
            const SizedBox(width: 15),
            _buildNumberButton(5),
            const SizedBox(width: 15),
            _buildNumberButton(6),
          ],
        ),
      ],
    );
  }
}
