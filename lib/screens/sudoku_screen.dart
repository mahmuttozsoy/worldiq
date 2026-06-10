import 'dart:async';
import 'package:world_iq/providers/l10n_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../utils/sudoku_16_generator.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../services/sound_service.dart';
import 'package:world_iq/services/firebase_service.dart';


class SudokuScreen extends ConsumerStatefulWidget {
  final String? initialDifficulty;
  const SudokuScreen({super.key, this.initialDifficulty});

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    if (widget.initialDifficulty != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLevel(widget.initialDifficulty!);
      });
    }
  }

  int _gridSize = 9;
  int _subGridRows = 3;
  int _subGridCols = 3;

  // New Puzzles with different sizes
  final Map<String, Map<String, dynamic>> _puzzleData = {
    'Başlangıç (4x4)': {
      'size': 4,
      'subRows': 2,
      'subCols': 2,
      'grid': [
        [1, 0, 0, 0],
        [0, 0, 2, 0],
        [0, 3, 0, 0],
        [0, 0, 0, 4],
      ],
      'solution': List.generate(
        4,
        (r) => List.generate(4, (c) => ((r * 2 + r ~/ 2 + c) % 4 + 1)),
      ),
    },
    'Amatör (6x6)': {
      'size': 6,
      'subRows': 2,
      'subCols': 3,
      'grid': [
        [1, 0, 0, 0, 0, 4],
        [0, 0, 2, 5, 0, 0],
        [0, 5, 0, 0, 2, 0],
        [0, 2, 0, 0, 6, 0],
        [0, 0, 4, 1, 0, 0],
        [2, 0, 0, 0, 0, 3],
      ],
      'solution': List.generate(
        6,
        (r) => List.generate(6, (c) => ((r * 3 + r ~/ 2 + c) % 6 + 1)),
      ),
    },
    'Profesyonel (9x9)': {
      'size': 9,
      'subRows': 3,
      'subCols': 3,
      'grid': [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ],
      'solution': List.generate(
        9,
        (r) => List.generate(9, (c) => ((r * 3 + r ~/ 3 + c) % 9 + 1)),
      ),
    },
    'Efsane (16x16)': {
      'size': 16,
      'subRows': 4,
      'subCols': 4,
      'grid': List.generate(
        16,
        (r) => List.generate(16, (c) => (r == c ? (r + 1) : 0)),
      ),
      'solution': List.generate(
        16,
        (r) => List.generate(16, (c) => ((r * 4 + r ~/ 4 + c) % 16 + 1)),
      ),
    },
  };

  late List<List<int>> _initialGrid;
  late List<List<int>> _currentGrid;
  late List<List<int>> _solutionGrid;
  late List<List<Set<int>>> _notesGrid;

  bool _isNotesMode = false;
  int _errors = 0;
  final int _maxErrors = 3;
  int _hintsLeft = 3;

  int? _selectedRow;
  int? _selectedCol;

  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  List<List<int>> _copyGrid(List<List<int>> grid) {
    return grid.map((row) => List<int>.from(row)).toList();
  }

  bool _isSafe(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < _gridSize; i++) {
      if (board[row][i] == num) return false;
      if (board[i][col] == num) return false;
    }

    final startRow = (row ~/ _subGridRows) * _subGridRows;
    final startCol = (col ~/ _subGridCols) * _subGridCols;

    for (int r = 0; r < _subGridRows; r++) {
      for (int c = 0; c < _subGridCols; c++) {
        if (board[startRow + r][startCol + c] == num) return false;
      }
    }

    return true;
  }

  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (board[row][col] == 0) {
          final numbers = List<int>.generate(_gridSize, (i) => i + 1)
            ..shuffle();

          for (final num in numbers) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;

              if (_fillBoard(board)) return true;

              board[row][col] = 0;
            }
          }

          return false;
        }
      }
    }

    return true;
  }

  int _countSolutions(List<List<int>> board, {int limit = 2}) {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (board[row][col] == 0) {
          int count = 0;

          for (int num = 1; num <= _gridSize; num++) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;
              count += _countSolutions(board, limit: limit);
              board[row][col] = 0;

              if (count >= limit) return count;
            }
          }

          return count;
        }
      }
    }

    return 1;
  }

  bool _hasUniqueSolution(List<List<int>> board) {
    final copy = _copyGrid(board);
    return _countSolutions(copy, limit: 2) == 1;
  }

  int _getFilledCellCount(String level) {
    if (_gridSize == 4) return 6;
    if (_gridSize == 6) return 14;

    if (level.contains('Profesyonel')) return 32;
    if (level.contains('Efsane')) return 64;

    return 32;
  }

  void _startLevel(String level) {
    final data = _puzzleData[level]!;

    setState(() {
      _selectedDifficulty = level;
      _gridSize = data['size'];
      _subGridRows = data['subRows'];
      _subGridCols = data['subCols'];

      if (_gridSize == 16) {
        // Use high-performance generator for 16x16 to avoid crashes
        final generator = Sudoku16Generator();
        final result = generator.generate('Orta'); // Can be mapped to level
        _initialGrid = result['puzzle']!;
        _solutionGrid = result['solution']!;
      } else {
        // Use backtracking for 4x4, 6x6, 9x9 (safe for these sizes)
        _solutionGrid = List.generate(
          _gridSize,
          (_) => List.generate(_gridSize, (_) => 0),
        );

        _fillBoard(_solutionGrid);
        _initialGrid = _copyGrid(_solutionGrid);

        final targetFilledCells = _getFilledCellCount(level);
        final totalCells = _gridSize * _gridSize;
        final cellsToRemove = totalCells - targetFilledCells;

        final positions = <List<int>>[];
        for (int r = 0; r < _gridSize; r++) {
          for (int c = 0; c < _gridSize; c++) {
            positions.add([r, c]);
          }
        }
        positions.shuffle();

        int removed = 0;
        for (final pos in positions) {
          if (removed >= cellsToRemove) break;
          final row = pos[0];
          final col = pos[1];
          final backup = _initialGrid[row][col];
          _initialGrid[row][col] = 0;

          if (_hasUniqueSolution(_initialGrid)) {
            removed++;
          } else {
            _initialGrid[row][col] = backup;
          }
        }
      }

      _currentGrid = _copyGrid(_initialGrid);
      _notesGrid = List.generate(
        _gridSize,
        (_) => List.generate(_gridSize, (_) => <int>{}),
      );

      _errors = 0;
      _hintsLeft = 3;
      _seconds = 0;
      _selectedRow = null;
      _selectedCol = null;
      _isNotesMode = false;

      _startTimer();
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getDisplayValue(int value) {
    if (value == 0) return '';
    if (_gridSize == 16 && value > 9) {
      return String.fromCharCode(65 + (value - 10)); // 10 -> A, 11 -> B, etc.
    }
    return '$value';
  }

  void _onCellTap(int row, int col) {
    if (_errors >= _maxErrors) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
    HapticFeedback.lightImpact();
  }

  void _useHint() {
    if (_selectedRow != null && _selectedCol != null && _hintsLeft > 0) {
      int r = _selectedRow!;
      int c = _selectedCol!;
      if (_initialGrid[r][c] == 0 &&
          _currentGrid[r][c] != _solutionGrid[r][c]) {
        setState(() {
          _currentGrid[r][c] = _solutionGrid[r][c];
          _notesGrid[r][c].clear();
          _hintsLeft--;
        });
        ref.read(soundServiceProvider).playCorrect();
        HapticFeedback.lightImpact();
        _checkWin();
      }
    }
  }

  void _onNumberTap(int number) {
    if (_selectedRow != null && _selectedCol != null) {
      int row = _selectedRow!;
      int col = _selectedCol!;
      if (_initialGrid[row][col] != 0) return;

      if (_isNotesMode && number != 0) {
        setState(() {
          if (_notesGrid[row][col].contains(number)) {
            _notesGrid[row][col].remove(number);
          } else {
            _notesGrid[row][col].add(number);
          }
        });
        return;
      }

      setState(() {
        if (number == 0) {
          _currentGrid[row][col] = 0;
          _notesGrid[row][col].clear();
        } else {
          if (number == _solutionGrid[row][col]) {
            _currentGrid[row][col] = number;
            _notesGrid[row][col].clear();
            ref.read(soundServiceProvider).playCorrect();
            HapticFeedback.lightImpact();
            _checkWin();
          } else {
            _errors++;
            ref.read(soundServiceProvider).playWrong();
            HapticFeedback.heavyImpact();
            if (_errors >= _maxErrors) {
              _showGameOver();
            } else {
              _currentGrid[row][col] = 0; // Auto-clear on error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${l10n.translate('wrong_number_msg')} ${l10n.translate('streak')}: ${_maxErrors - _errors}',
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(milliseconds: 500),
                ),
              );
            }
          }
        }
      });
    }
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_currentGrid[i][j] != _solutionGrid[i][j]) {
          win = false;
          break;
        }
      }
    }
    if (win) {
      _timer?.cancel();
      // Award XP based on difficulty
      int xp = 2; // Default for 4x4
      if (_gridSize == 6) xp = 4;
      if (_gridSize == 9) xp = 8;
      if (_gridSize == 16) xp = 20;

      ref.read(userProgressProvider.notifier).addScore(xp);
      _showWinDialog();
    }
  }

  void _showGameOver() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          l10n.translate('game_over_loss'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Text(
          l10n.translate('logout_confirm_desc'),
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedDifficulty = null);
            },
            child: Text(
              l10n.translate('return_to_menu'),
              style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startLevel(_selectedDifficulty!);
            },
            child: const Text(
              'Tekrar Dene',
              style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> _getNumberCounts() {
    Map<int, int> counts = {};
    for (int i = 1; i <= _gridSize; i++) {
      counts[i] = 0;
    }
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        int val = _currentGrid[i][j];
        if (val != 0 && val == _solutionGrid[i][j]) {
          counts[val] = (counts[val] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  void _showWinDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    _timer?.cancel();
    ref.read(soundServiceProvider).playFinish();

    // Save match result and award XP
    int xp = 20;
    if (_selectedDifficulty == 'Amatör (6x6)') xp = 40;
    if (_selectedDifficulty == 'Profesyonel (9x9)') xp = 100;
    if (_selectedDifficulty == 'Efsane (16x16)') xp = 250;

    ref.read(userProgressProvider.notifier).addScore(xp);
    ref.read(firebaseServiceProvider).saveMatchResult('Sudoku', true, xp);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
              const SizedBox(height: 24),
              Text(
                l10n.translate('perfect'),
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_selectedDifficulty ${l10n.translate('level_completed_msg')}',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WinStat(
                    label: l10n.translate('time_label'),
                    value: _formatTime(_seconds),
                    icon: Icons.timer,
                  ),
                  _WinStat(
                    label: l10n.translate('errors_label').toUpperCase(),
                    value: '$_errors',
                    icon: Icons.error_outline,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _selectedDifficulty = null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.translate('done'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    if (_selectedDifficulty == null) {
      return GradientScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.grid_4x4_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'WorldIQ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SUDOKU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('sudoku_lobby_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 34),
                _DifficultyButton(
                  title: l10n.translate('sudoku_level_4x4'),
                  subtitle: l10n.translate('sudoku_level_4x4_desc'),
                  icon: Icons.grid_view_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => _startLevel('Başlangıç (4x4)'),
                ),
                const SizedBox(height: 14),
                _DifficultyButton(
                  title: l10n.translate('sudoku_level_6x6'),
                  subtitle: l10n.translate('sudoku_level_6x6_desc'),
                  icon: Icons.grid_3x3_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => _startLevel('Amatör (6x6)'),
                ),
                const SizedBox(height: 14),
                _DifficultyButton(
                  title: l10n.translate('sudoku_level_9x9'),
                  subtitle: l10n.translate('sudoku_level_9x9_desc'),
                  icon: Icons.grid_4x4_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: () => _startLevel('Profesyonel (9x9)'),
                ),
                const SizedBox(height: 14),
                _DifficultyButton(
                  title: l10n.translate('sudoku_level_16x16'),
                  subtitle: l10n.translate('sudoku_level_16x16_desc'),
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: () => _startLevel('Efsane (16x16)'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final numberCounts = _getNumberCounts();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Sudoku - $_selectedDifficulty',
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer?.cancel();
            setState(() => _selectedDifficulty = null);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Game Stats & Timer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GameStatPill(
                  label: l10n.translate('errors_label'),
                  value: '$_errors/$_maxErrors',
                  icon: Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                ),
                _GameStatPill(
                  label: l10n.translate('streak'),
                  value: _formatTime(_seconds),
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF6366F1),
                ),
                _GameStatPill(
                  label: l10n.translate('hints_label'),
                  value: '$_hintsLeft',
                  icon: Icons.lightbulb_outline_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AspectRatio(
              aspectRatio: 1,
              child: GlassContainer(
                padding: const EdgeInsets.all(4),
                borderRadius: 20,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, index) {
                    int row = index ~/ _gridSize;
                    int col = index % _gridSize;
                    int value = _currentGrid[row][col];
                    bool initial = _initialGrid[row][col] != 0;
                    bool isSelected =
                        _selectedRow == row && _selectedCol == col;

                    int? selectedValue =
                        (_selectedRow != null && _selectedCol != null)
                        ? _currentGrid[_selectedRow!][_selectedCol!]
                        : null;

                    bool isSameNumberHighlight =
                        selectedValue != null &&
                        selectedValue != 0 &&
                        value == selectedValue;
                    bool isRelatedHighlight =
                        _selectedRow != null &&
                        _selectedCol != null &&
                        (_selectedRow == row ||
                            _selectedCol == col ||
                            (row ~/ _subGridRows ==
                                    _selectedRow! ~/ _subGridRows &&
                                col ~/ _subGridCols ==
                                    _selectedCol! ~/ _subGridCols));

                    bool isWrong =
                        !initial &&
                        value != 0 &&
                        value != _solutionGrid[row][col];

                    return GestureDetector(
                      onTap: () => _onCellTap(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color:
                                  (col + 1) % _subGridCols == 0 &&
                                      col != _gridSize - 1
                                  ? textColor.withValues(alpha: 0.2)
                                  : textColor.withValues(alpha: 0.05),
                              width: (col + 1) % _subGridCols == 0 ? 1.5 : 0.5,
                            ),
                            bottom: BorderSide(
                              color:
                                  (row + 1) % _subGridRows == 0 &&
                                      row != _gridSize - 1
                                  ? textColor.withValues(alpha: 0.2)
                                  : textColor.withValues(alpha: 0.05),
                              width: (row + 1) % _subGridRows == 0 ? 1.5 : 0.5,
                            ),
                          ),
                          color: isWrong
                              ? const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.15)
                              : (isSelected
                                    ? const Color(0xFF6366F1).withValues(alpha: isDark ? 0.35 : 0.2)
                                    : (isSameNumberHighlight
                                          ? const Color(0xFF6366F1).withValues(
                                              alpha: isDark ? 0.2 : 0.1,
                                            )
                                          : (isRelatedHighlight
                                                ? textColor.withValues(alpha: 0.03)
                                                : Colors.transparent))),
                        ),
                        alignment: Alignment.center,
                        child: value != 0
                            ? Text(
                                _getDisplayValue(value),
                                style: TextStyle(
                                  fontSize: _gridSize == 16
                                      ? 12
                                      : (_gridSize == 9 ? 22 : 28),
                                  fontWeight: initial
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: isWrong
                                      ? (isDark ? Colors.white : const Color(0xFFEF4444))
                                      : (initial
                                            ? textColor
                                            : const Color(0xFF6366F1)),
                                ),
                              )
                            : _buildNotes(row, col, isDark, textColor),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: _isNotesMode ? Icons.edit_note : Icons.edit_outlined,
                  label:
                      '${l10n.translate('notes_label')}: ${_isNotesMode ? l10n.translate('on') : l10n.translate('off')}',
                  isActive: _isNotesMode,
                  onTap: () => setState(() => _isNotesMode = !_isNotesMode),
                ),
                _ActionButton(
                  icon: Icons.lightbulb_outline,
                  label: '${l10n.translate('hints_label')} ($_hintsLeft)',
                  onTap: _useHint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Number Pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ...List.generate(_gridSize, (index) => index + 1)
                      .where((n) => (numberCounts[n] ?? 0) < _gridSize)
                      .map(
                        (number) => _NumberButton(
                          number: number,
                          remaining: _gridSize - (numberCounts[number] ?? 0),
                          onTap: () => _onNumberTap(number),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildNotes(int row, int col, bool isDark, Color textColor) {
    final notes = _notesGrid[row][col].toList()..sort();
    if (notes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: notes
            .map(
              (n) => Text(
                _getDisplayValue(n),
                style: TextStyle(
                  fontSize: 9,
                  color: textColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _GameStatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _GameStatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 16,
      color: color.withValues(alpha: 0.05),
      border: Border.all(color: color.withValues(alpha: 0.15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.4),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final activeColor = const Color(0xFF6366F1);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isActive 
                ? activeColor.withValues(alpha: 0.15) 
                : textColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActive 
                  ? activeColor.withValues(alpha: 0.4) 
                  : textColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : textColor.withValues(alpha: 0.6),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : textColor.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WinStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final int? remaining;
  final VoidCallback onTap;
  const _NumberButton({
    required this.number,
    this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: remaining != null ? 52 : 58,
        height: remaining != null ? 52 : 58,
        borderRadius: 16,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        color: textColor.withValues(alpha: isDark ? 0.08 : 0.04),
        border: Border.all(
          color: textColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1.5,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              _getDisplayLabel(),
              style: TextStyle(
                fontSize: remaining != null ? 19 : 24,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            if (remaining != null)
              Positioned(
                right: 6,
                bottom: 4,
                child: Text(
                  '$remaining',
                  style: TextStyle(
                    fontSize: 9,
                    color: textColor.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getDisplayLabel() {
    if (number == 0) return '';
    if (number > 9) {
      return String.fromCharCode(65 + (number - 10)); // A, B, C...
    }
    return '$number';
  }
}

class _DifficultyButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.5,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
