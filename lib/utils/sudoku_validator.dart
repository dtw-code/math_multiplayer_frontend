/// Frontend validation utilities for a 6x6 Sudoku grid.
///
/// The grid uses 2×3 blocks (2 rows × 3 columns).
/// Valid numbers are 1–6. Empty cells are represented by 0 or null.
class SudokuValidator {
  /// Returns true if every cell is filled (no 0 or null values).
  static bool isGridComplete(List<List<int?>> grid) {
    for (final row in grid) {
      for (final cell in row) {
        if (cell == null || cell == 0) return false;
      }
    }
    return true;
  }

  /// Checks whether placing [num] at ([row], [col]) violates any Sudoku rule.
  ///
  /// Returns true if valid (no conflict), false if there is a duplicate in
  /// the same row, column, or 2×3 block.
  /// [ignoreself] — when true, skips the cell itself during the check
  /// (useful when the value is already placed in the grid).
  static bool isCellValid(
    List<List<int?>> grid,
    int row,
    int col,
    int num, {
    bool ignoreSelf = true,
  }) {
    if (num < 1 || num > 6) return false;

    // Check row
    for (int c = 0; c < 6; c++) {
      if (ignoreSelf && c == col) continue;
      if (grid[row][c] == num) return false;
    }

    // Check column
    for (int r = 0; r < 6; r++) {
      if (ignoreSelf && r == row) continue;
      if (grid[r][col] == num) return false;
    }

    // Check 2×3 block
    final startRow = (row ~/ 2) * 2;
    final startCol = (col ~/ 3) * 3;
    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 3; c++) {
        final br = startRow + r;
        final bc = startCol + c;
        if (ignoreSelf && br == row && bc == col) continue;
        if (grid[br][bc] == num) return false;
      }
    }

    return true;
  }

  /// Returns a set of (row, col) positions where Sudoku rules are violated.
  ///
  /// Only checks filled cells (non-null and non-zero).
  static Set<(int, int)> findConflicts(List<List<int?>> grid) {
    final conflicts = <(int, int)>{};

    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        final value = grid[row][col];
        if (value == null || value == 0) continue;

        if (!isCellValid(grid, row, col, value, ignoreSelf: true)) {
          conflicts.add((row, col));
        }
      }
    }

    return conflicts;
  }

  /// Returns true if the grid is completely filled and has no conflicts.
  static bool isGridValidAndComplete(List<List<int?>> grid) {
    return isGridComplete(grid) && findConflicts(grid).isEmpty;
  }
}
