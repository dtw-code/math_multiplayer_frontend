import 'package:flutter/material.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends StatelessWidget {
  final List<List<int?>> grid;
  final int? selectedRow;
  final int? selectedCol;
  final int? highlightedNumber;
  final Function(int, int) onCellTapped;

  const SudokuBoard({
    Key? key,
    required this.grid,
    this.selectedRow,
    this.selectedCol,
    this.highlightedNumber,
    required this.onCellTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 305,
      decoration: const BoxDecoration(
        // Outer border completing the thick box effect
        border: Border(
          top: BorderSide(color: Color(0xFF4033B8), width: 4.0),
          left: BorderSide(color: Color(0xFF4033B8), width: 4.0),
          // The bottom and right outer borders are handled by the cells themselves,
          // but we can add them here for symmetry without issue.
          right: BorderSide(color: Color(0xFF4033B8), width: 1.0),
          bottom: BorderSide(color: Color(0xFF4033B8), width: 1.0),
        ),
      ),
      child: Column(
        children: List.generate(6, (row) {
          return Expanded(
            child: Row(
              children: List.generate(6, (col) {
                bool isSelected = selectedRow == row && selectedCol == col;
                bool isRelated = selectedRow == row || selectedCol == col;
                bool isSameNumber = false;
                // highlightedNumber != null &&
                // grid[row][col] == highlightedNumber;

                // Thicker borders for the 3x2 blocks
                bool bottomThick = (row == 1 || row == 3 || row == 5);
                bool rightThick = (col == 2 || col == 5);

                return Expanded(
                  child: SudokuCell(
                    value: grid[row][col],
                    row: row,
                    col: col,
                    isSelected: isSelected,
                    isRelated: isRelated,
                    isSameNumber: isSameNumber,
                    bottomThick: bottomThick,
                    rightThick: rightThick,
                    onTap: () => onCellTapped(row, col),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
