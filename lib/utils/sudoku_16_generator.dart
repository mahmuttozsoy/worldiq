import 'dart:math';

class Sudoku16Generator {
  static const int size = 16;
  static const int subGridSize = 4;

  final Random _random = Random();

  /// Generates a playable 16x16 Sudoku puzzle.
  /// Returns a Map with 'puzzle' and 'solution' as `List<List<int>>`.
  Map<String, List<List<int>>> generate(String difficulty) {
    // 1. Generate full board using pattern
    List<List<int>> board = _generateFullBoard();

    // 2. Shuffle for variety
    _shuffleBoard(board);

    // 3. Create solution copy
    List<List<int>> solution = board.map((row) => List<int>.from(row)).toList();

    // 4. Remove cells based on difficulty
    int targetFilled = _getTargetFilled(difficulty);
    _removeCellsSymmetric(board, targetFilled);

    return {
      'puzzle': board,
      'solution': solution,
    };
  }

  List<List<int>> _generateFullBoard() {
    return List.generate(size, (r) {
      return List.generate(size, (c) {
        // Standard high-performance Sudoku pattern
        return ((r * subGridSize + r ~/ subGridSize + c) % size) + 1;
      });
    });
  }

  void _shuffleBoard(List<List<int>> board) {
    // Shuffle numbers (1-16 mapping)
    List<int> mapping = List.generate(size, (i) => i + 1)..shuffle(_random);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        board[r][c] = mapping[board[r][c] - 1];
      }
    }

    // Shuffle rows within blocks
    for (int block = 0; block < subGridSize; block++) {
      List<int> rows = List.generate(subGridSize, (i) => block * subGridSize + i)..shuffle(_random);
      List<List<int>> tempRows = rows.map((r) => List<int>.from(board[r])).toList();
      for (int i = 0; i < subGridSize; i++) {
        board[block * subGridSize + i] = tempRows[i];
      }
    }

    // Shuffle columns within blocks
    for (int block = 0; block < subGridSize; block++) {
      List<int> cols = List.generate(subGridSize, (i) => block * subGridSize + i)..shuffle(_random);
      for (int r = 0; r < size; r++) {
        List<int> tempRow = List.from(board[r]);
        for (int i = 0; i < subGridSize; i++) {
          board[r][block * subGridSize + i] = tempRow[cols[i]];
        }
      }
    }
  }

  void _removeCellsSymmetric(List<List<int>> board, int targetFilled) {
    int totalCells = size * size;
    int toRemove = totalCells - targetFilled;
    
    // Create list of all symmetric positions
    List<Point<int>> positions = [];
    for (int r = 0; r < size / 2; r++) {
      for (int c = 0; c < size; c++) {
        positions.add(Point(r, c));
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (var pos in positions) {
      if (removed >= toRemove) break;

      int r1 = pos.x;
      int c1 = pos.y;
      int r2 = (size - 1) - r1;
      int c2 = (size - 1) - c1;

      if (board[r1][c1] != 0) {
        board[r1][c1] = 0;
        board[r2][c2] = 0;
        removed += 2;
      }
    }
  }

  int _getTargetFilled(String difficulty) {
    if (difficulty.contains('Kolay')) return 150;
    if (difficulty.contains('Orta')) return 130;
    if (difficulty.contains('Zor')) return 110;
    return 130; // Default Orta
  }
}
