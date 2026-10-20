import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SudokuCell extends StatelessWidget {
  final int? value;
  final int row;
  final int col;
  final bool isSelected;
  final bool isRelated;
  final bool isSameNumber;
  final bool isConflict;
  final bool bottomThick;
  final bool rightThick;
  final VoidCallback onTap;

  const SudokuCell({
    Key? key,
    this.value,
    required this.row,
    required this.col,
    this.isSelected = false,
    this.isRelated = false,
    this.isSameNumber = false,
    this.isConflict = false,
    this.bottomThick = false,
    this.rightThick = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white70;

    if (isSelected) {
      bgColor = const Color(0xFF4033B8).withOpacity(0.5);
    } else if (isConflict) {
      bgColor = const Color(0xFFFF4444).withOpacity(0.35);
      textColor = const Color(0xFFFF6B6B);
    } else if (isSameNumber) {
      bgColor = const Color(0xFF45E0E5).withOpacity(0.3);
    } else if (isRelated) {
      bgColor = Colors.white.withOpacity(0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF4033B8),
              width: bottomThick
                  ? 4.0
                  : 1.0, // Increased weight for bold grid lines
            ),
            right: BorderSide(
              color: const Color(0xFF4033B8),
              width: rightThick
                  ? 4.0
                  : 1.0, // Increased weight for bold grid lines
            ),
          ),
        ),
        alignment: Alignment.center,
        child: value != null
            ? Text(
                value.toString(),
                style: GoogleFonts.inriaSans(
                  color: textColor,
                  fontSize: 24,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
