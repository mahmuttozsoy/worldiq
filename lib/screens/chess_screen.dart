import 'dart:async';
import 'package:world_iq/providers/l10n_extension.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../services/sound_service.dart';
import 'package:world_iq/services/firebase_service.dart';

class ChessScreen extends ConsumerStatefulWidget {
  final String? initialDifficulty;
  final String? sessionId;
  final bool? isHost;

  const ChessScreen({
    super.key,
    this.initialDifficulty,
    this.sessionId,
    this.isHost,
  });

  @override
  ConsumerState<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends ConsumerState<ChessScreen> {
  String? _selectedDifficulty;
  StreamSubscription? _movesSub;

  @override
  void initState() {
    super.initState();
    if (widget.initialDifficulty != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLevel(widget.initialDifficulty!);
      });
    }

    if (widget.sessionId != null) {
      _listenToMoves();
    }

    // Initial status text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _statusText = l10n.translate('white_turn');
      });
    });
  }

  void _listenToMoves() {
    _movesSub = ref
        .read(firebaseServiceProvider)
        .getChessMovesStream(widget.sessionId!)
        .listen((moves) {
          if (moves.isEmpty) return;

          final lastMove = moves.last;
          final playerUid = lastMove['playerUid'];

          if (playerUid != ref.read(firebaseServiceProvider).currentUser?.uid) {
            final moveStr = lastMove['move'] as String;
            final parts = moveStr.split(',');
            final fromRow = int.parse(parts[0]);
            final fromCol = int.parse(parts[1]);
            final toRow = int.parse(parts[2]);
            final toCol = int.parse(parts[3]);

            setState(() {
              _makeMoveOnBoard(_board, fromRow, fromCol, toRow, toCol);
              _lastMoveFromRow = fromRow;
              _lastMoveFromCol = fromCol;
              _lastMoveToRow = toRow;
              _lastMoveToCol = toCol;
              _whiteTurn = !_whiteTurn;
              _updateGameStatus();
            });
          }
        });
  }

  @override
  void dispose() {
    _movesSub?.cancel();
    super.dispose();
  }

  List<List<String>> _board = _initialBoard();

  int? _selectedRow;
  int? _selectedCol;
  int? _lastMoveFromRow;
  int? _lastMoveFromCol;
  int? _lastMoveToRow;
  int? _lastMoveToCol;

  bool _whiteTurn = true;
  bool _gameOver = false;
  String _statusText = ''; // Initialized in initState / resetGame

  final Random _random = Random();

  static List<List<String>> _initialBoard() {
    return [
      ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
      ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
      ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
    ];
  }

  final Map<String, String> pieceEmojis = {
    'r': '♜',
    'n': '♞',
    'b': '♝',
    'q': '♛',
    'k': '♚',
    'p': '♟',
    'R': '♖',
    'N': '♘',
    'B': '♗',
    'Q': '♕',
    'K': '♔',
    'P': '♙',
  };

  final Map<String, int> pieceValues = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };

  void _startLevel(String level) {
    setState(() {
      _selectedDifficulty = level;
      _resetGame();
    });
  }

  void _resetGame() {
    _board = _initialBoard();
    _selectedRow = null;
    _selectedCol = null;
    _lastMoveFromRow = null;
    _lastMoveFromCol = null;
    _lastMoveToRow = null;
    _lastMoveToCol = null;
    _whiteTurn = true;
    _gameOver = false;
    final l10n = AppLocalizations.of(context)!;
    _statusText = l10n.translate('white_turn');
  }

  bool _isWhitePiece(String piece) {
    if (piece.isEmpty) return false;
    return 'RNBAQKP'.contains(piece);
  }

  bool _isBlackPiece(String piece) {
    return piece.isNotEmpty && piece == piece.toLowerCase();
  }

  bool _isOwnPiece(String piece, bool white) {
    if (piece.isEmpty) return false;
    return white ? _isWhitePiece(piece) : _isBlackPiece(piece);
  }

  bool _isEnemyPiece(String piece, bool white) {
    if (piece.isEmpty) return false;
    return white ? _isBlackPiece(piece) : _isWhitePiece(piece);
  }

  bool _inside(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  List<List<String>> _copyBoard(List<List<String>> board) {
    return board.map((row) => List<String>.from(row)).toList();
  }

  bool _isPathClear(
    List<List<String>> board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    final rowStep = (toRow - fromRow).sign;
    final colStep = (toCol - fromCol).sign;

    int r = fromRow + rowStep;
    int c = fromCol + colStep;

    while (r != toRow || c != toCol) {
      if (board[r][c].isNotEmpty) return false;
      r += rowStep;
      c += colStep;
    }

    return true;
  }

  bool _isBasicMoveValid(
    List<List<String>> board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    if (!_inside(toRow, toCol)) return false;
    if (fromRow == toRow && fromCol == toCol) return false;

    final piece = board[fromRow][fromCol];
    if (piece.isEmpty) return false;

    final white = _isWhitePiece(piece);
    final target = board[toRow][toCol];

    if (_isOwnPiece(target, white)) return false;

    final lower = piece.toLowerCase();
    final rowDiff = toRow - fromRow;
    final colDiff = toCol - fromCol;
    final absRow = rowDiff.abs();
    final absCol = colDiff.abs();

    switch (lower) {
      case 'p':
        final direction = white ? -1 : 1;
        final startRow = white ? 6 : 1;

        if (colDiff == 0 && target.isEmpty) {
          if (rowDiff == direction) return true;

          if (fromRow == startRow &&
              rowDiff == direction * 2 &&
              board[fromRow + direction][fromCol].isEmpty) {
            return true;
          }
        }

        if (absCol == 1 &&
            rowDiff == direction &&
            _isEnemyPiece(target, white)) {
          return true;
        }

        return false;

      case 'r':
        if (fromRow == toRow || fromCol == toCol) {
          return _isPathClear(board, fromRow, fromCol, toRow, toCol);
        }
        return false;

      case 'n':
        return (absRow == 2 && absCol == 1) || (absRow == 1 && absCol == 2);

      case 'b':
        if (absRow == absCol) {
          return _isPathClear(board, fromRow, fromCol, toRow, toCol);
        }
        return false;

      case 'q':
        if (fromRow == toRow || fromCol == toCol || absRow == absCol) {
          return _isPathClear(board, fromRow, fromCol, toRow, toCol);
        }
        return false;

      case 'k':
        return absRow <= 1 && absCol <= 1;

      default:
        return false;
    }
  }

  bool _isSquareAttacked(
    List<List<String>> board,
    int row,
    int col,
    bool byWhite,
  ) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece.isEmpty) continue;
        if (_isOwnPiece(piece, byWhite)) {
          if (_isBasicMoveValid(board, r, c, row, col)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _isKingInCheck(List<List<String>> board, bool whiteKing) {
    String king = whiteKing ? 'K' : 'k';

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] == king) {
          return _isSquareAttacked(board, r, c, !whiteKing);
        }
      }
    }

    return true;
  }

  bool _isLegalMove(
    List<List<String>> board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
    bool white,
  ) {
    final piece = board[fromRow][fromCol];

    if (piece.isEmpty) return false;
    if (!_isOwnPiece(piece, white)) return false;

    if (!_isBasicMoveValid(board, fromRow, fromCol, toRow, toCol)) {
      return false;
    }

    final testBoard = _copyBoard(board);
    _makeMoveOnBoard(testBoard, fromRow, fromCol, toRow, toCol);

    return !_isKingInCheck(testBoard, white);
  }

  void _makeMoveOnBoard(
    List<List<String>> board,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) {
    String piece = board[fromRow][fromCol];

    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = '';

    if (piece == 'P' && toRow == 0) {
      board[toRow][toCol] = 'Q';
    } else if (piece == 'p' && toRow == 7) {
      board[toRow][toCol] = 'q';
    }
  }

  List<ChessMove> _getLegalMoves(List<List<String>> board, bool white) {
    final moves = <ChessMove>[];

    for (int fromRow = 0; fromRow < 8; fromRow++) {
      for (int fromCol = 0; fromCol < 8; fromCol++) {
        final piece = board[fromRow][fromCol];

        if (!_isOwnPiece(piece, white)) continue;

        for (int toRow = 0; toRow < 8; toRow++) {
          for (int toCol = 0; toCol < 8; toCol++) {
            if (_isLegalMove(board, fromRow, fromCol, toRow, toCol, white)) {
              moves.add(ChessMove(fromRow, fromCol, toRow, toCol));
            }
          }
        }
      }
    }

    return moves;
  }

  int _evaluateBoard(List<List<String>> board) {
    int score = 0;

    for (final row in board) {
      for (final piece in row) {
        if (piece.isEmpty) continue;

        final value = pieceValues[piece.toLowerCase()] ?? 0;

        if (_isWhitePiece(piece)) {
          score += value;
        } else {
          score -= value;
        }
      }
    }

    return score;
  }

  int _getAIDepth() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDifficulty == l10n.translate('beginner')) return 1;
    if (_selectedDifficulty == l10n.translate('pro')) return 2;
    if (_selectedDifficulty == l10n.translate('champion')) return 3;
    return 1;
  }

  ChessMove? _getBestAIMove() {
    final moves = _getLegalMoves(_board, false);
    if (moves.isEmpty) return null;

    final l10n = AppLocalizations.of(context)!;
    if (_selectedDifficulty == l10n.translate('beginner')) {
      return moves[_random.nextInt(moves.length)];
    }

    int bestScore = 999999999;
    ChessMove? bestMove;

    for (final move in moves) {
      final testBoard = _copyBoard(_board);
      _makeMoveOnBoard(
        testBoard,
        move.fromRow,
        move.fromCol,
        move.toRow,
        move.toCol,
      );

      final score = _minimax(
        testBoard,
        _getAIDepth() - 1,
        -999999999,
        999999999,
        true,
      );

      if (score < bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _minimax(
    List<List<String>> board,
    int depth,
    int alpha,
    int beta,
    bool maximizingWhite,
  ) {
    if (depth == 0) return _evaluateBoard(board);

    final moves = _getLegalMoves(board, maximizingWhite);

    if (moves.isEmpty) {
      if (_isKingInCheck(board, maximizingWhite)) {
        return maximizingWhite ? -999999 : 999999;
      }
      return 0;
    }

    if (maximizingWhite) {
      int maxEval = -999999999;

      for (final move in moves) {
        final testBoard = _copyBoard(board);
        _makeMoveOnBoard(
          testBoard,
          move.fromRow,
          move.fromCol,
          move.toRow,
          move.toCol,
        );

        final eval = _minimax(testBoard, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);

        if (beta <= alpha) break;
      }

      return maxEval;
    } else {
      int minEval = 999999999;

      for (final move in moves) {
        final testBoard = _copyBoard(board);
        _makeMoveOnBoard(
          testBoard,
          move.fromRow,
          move.fromCol,
          move.toRow,
          move.toCol,
        );

        final eval = _minimax(testBoard, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);

        if (beta <= alpha) break;
      }

      return minEval;
    }
  }

  void _updateGameStatus() {
    final legalMoves = _getLegalMoves(_board, _whiteTurn);
    final inCheck = _isKingInCheck(_board, _whiteTurn);

    final l10n = AppLocalizations.of(context)!;
    if (legalMoves.isEmpty) {
      _gameOver = true;
      String resultTitle = '';
      String resultMessage = '';
      bool isWin = false;
      int winXp = 0;

      if (inCheck) {
        if (_whiteTurn) {
          resultTitle = l10n.translate('game_over_loss');
          resultMessage = '${l10n.translate('game_over_loss')} ${l10n.translate('black_won')}';
          _statusText = resultMessage;
          isWin = false;
          ref.read(soundServiceProvider).playError();
          if (widget.sessionId == null || widget.isHost == true) {
            ref
                .read(firebaseServiceProvider)
                .saveMatchResult(l10n.translate('chess_game'), false, 0);
          }
        } else {
          resultTitle = l10n.translate('perfect');
          isWin = true;
          int xp = 5;
          if (_selectedDifficulty == l10n.translate('pro')) xp = 15;
          if (_selectedDifficulty == l10n.translate('champion')) xp = 40;
          winXp = xp;
          resultMessage = l10n.translate('win_xp_msg')
              .replaceAll('{msg}', l10n.translate('checkmate_white_won'))
              .replaceAll('{xp}', xp.toString());
          _statusText = l10n.translate('checkmate_white_won');
          ref.read(soundServiceProvider).playWin();

          if (widget.sessionId == null || widget.isHost == true) {
            ref.read(userProgressProvider.notifier).addScore(xp);
            ref
                .read(firebaseServiceProvider)
                .saveMatchResult(l10n.translate('chess_game'), true, xp);
          }
        }
      } else {
        resultTitle = l10n.translate('draw');
        resultMessage = l10n.translate('pat_msg');
        _statusText = resultMessage;
        ref.read(soundServiceProvider).playFinish();
        ref.read(firebaseServiceProvider).saveMatchResult(l10n.translate('chess_game'), false, 0);
      }

      _showGameOverDialog(resultTitle, resultMessage, isWin, winXp);
      return;
    }

    if (inCheck) {
      _statusText = _whiteTurn 
          ? l10n.translate('white_in_check') 
          : l10n.translate('black_in_check');
    } else {
      _statusText = _whiteTurn
          ? l10n.translate('white_turn')
          : l10n.translate('black_thinking');
    }
  }

  Future<void> _makeAIMove() async {
    if (_gameOver || _whiteTurn) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _statusText = l10n.translate('black_thinking');
    });

    await Future.delayed(const Duration(milliseconds: 350));

    final move = _getBestAIMove();

    if (move == null) {
      setState(() {
        _updateGameStatus();
      });
      return;
    }

    setState(() {
      final targetPiece = _board[move.toRow][move.toCol];
      _makeMoveOnBoard(
        _board,
        move.fromRow,
        move.fromCol,
        move.toRow,
        move.toCol,
      );

      if (targetPiece.isNotEmpty) {
        ref.read(soundServiceProvider).playChessCapture();
      } else {
        ref.read(soundServiceProvider).playChessMove();
      }

      _lastMoveFromRow = move.fromRow;
      _lastMoveFromCol = move.fromCol;
      _lastMoveToRow = move.toRow;
      _lastMoveToCol = move.toCol;
      _whiteTurn = true;
      _selectedRow = null;
      _selectedCol = null;
      _updateGameStatus();
    });
  }

  void _onCellTap(int row, int col) {
    if (_gameOver) return;

    if (widget.sessionId != null) {
      final isMyTurn = widget.isHost == true ? _whiteTurn : !_whiteTurn;
      if (!isMyTurn) return;
    } else {
      if (!_whiteTurn) return;
    }

    setState(() {
      final piece = _board[row][col];

      if (_selectedRow == null || _selectedCol == null) {
        final isCorrectColor = widget.sessionId != null
            ? (widget.isHost == true
                  ? _isWhitePiece(piece)
                  : _isBlackPiece(piece))
            : _isWhitePiece(piece);

        if (isCorrectColor) {
          _selectedRow = row;
          _selectedCol = col;
          HapticFeedback.lightImpact();
        }
        return;
      }

      final fromRow = _selectedRow!;
      final fromCol = _selectedCol!;

      if (fromRow == row && fromCol == col) {
        _selectedRow = null;
        _selectedCol = null;
        return;
      }

      final isSameColor = widget.sessionId != null
          ? (widget.isHost == true
                ? _isWhitePiece(piece)
                : _isBlackPiece(piece))
          : _isWhitePiece(piece);

      if (isSameColor) {
        _selectedRow = row;
        _selectedCol = col;
        HapticFeedback.lightImpact();
        return;
      }

      final myColor = widget.sessionId != null ? (widget.isHost == true) : true;

      if (_isLegalMove(_board, fromRow, fromCol, row, col, myColor)) {
        final targetPiece = _board[row][col];
        _makeMoveOnBoard(_board, fromRow, fromCol, row, col);

        if (targetPiece.isNotEmpty) {
          ref.read(soundServiceProvider).playChessCapture();
        } else {
          ref.read(soundServiceProvider).playChessMove();
        }

        _lastMoveFromRow = fromRow;
        _lastMoveFromCol = fromCol;
        _lastMoveToRow = row;
        _lastMoveToCol = col;

        if (widget.sessionId != null) {
          ref
              .read(firebaseServiceProvider)
              .sendChessMove(widget.sessionId!, '$fromRow,$fromCol,$row,$col');
        }

        _whiteTurn = !_whiteTurn;
        _selectedRow = null;
        _selectedCol = null;
        _updateGameStatus();
        HapticFeedback.mediumImpact();
      } else {
        final l10n = AppLocalizations.of(context)!;
        _statusText = l10n.translate('invalid_move');
        ref.read(soundServiceProvider).playError();
        HapticFeedback.heavyImpact();
      }
    });

    if (!_whiteTurn && !_gameOver && widget.sessionId == null) {
      _makeAIMove();
    }
  }

  List<ChessMove> _selectedPieceLegalMoves() {
    if (_selectedRow == null || _selectedCol == null) return [];
    final myColor = widget.sessionId != null ? (widget.isHost == true) : true;

    return _getLegalMoves(_board, myColor)
        .where(
          (move) =>
              move.fromRow == _selectedRow && move.fromCol == _selectedCol,
        )
        .toList();
  }

  int _pieceCount(bool white) {
    int count = 0;
    for (final row in _board) {
      for (final piece in row) {
        if (_isOwnPiece(piece, white)) count++;
      }
    }
    return count;
  }

  bool _isLastMoveCell(int row, int col) {
    return (_lastMoveFromRow == row && _lastMoveFromCol == col) ||
        (_lastMoveToRow == row && _lastMoveToCol == col);
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
          title: Text(
            l10n.translate('chess_arena'),
            style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
          ),
          centerTitle: true,
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
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('♛', style: TextStyle(fontSize: 56, color: Colors.white)),
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
                  l10n.translate('chess_arena'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.sessionId == null
                      ? l10n.translate('chess_desc')
                      : l10n.translate('online_match_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 34),
                _DifficultyButton(
                  title: l10n.translate('beginner'),
                  subtitle: l10n.translate('easy_desc'),
                  icon: Icons.school_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => _startLevel(l10n.translate('beginner')),
                ),
                const SizedBox(height: 14),
                _DifficultyButton(
                  title: l10n.translate('pro'),
                  subtitle: l10n.translate('medium_desc'),
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: () => _startLevel(l10n.translate('pro')),
                ),
                const SizedBox(height: 14),
                _DifficultyButton(
                  title: l10n.translate('champion'),
                  subtitle: l10n.translate('hard_desc'),
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF43F5E),
                  onTap: () => _startLevel(l10n.translate('champion')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final legalTargets = _selectedPieceLegalMoves()
        .map((move) => '${move.toRow},${move.toCol}')
        .toSet();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('chess_game')} - $_selectedDifficulty',
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => setState(() => _selectedDifficulty = null),
        ),
        actions: [
          IconButton(
            tooltip: l10n.translate('restart_game'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(_resetGame),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = min(constraints.maxWidth - 32, 430.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      _StatusPanel(
                        statusText: _statusText,
                        whiteTurn: _whiteTurn,
                        gameOver: _gameOver,
                        difficulty: _selectedDifficulty ?? 'Acemi',
                        whitePieces: _pieceCount(true),
                        blackPieces: _pieceCount(false),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: boardSize,
                        height: boardSize,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: isDark ? Colors.white10 : Colors.white,
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF0F172A).withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                            itemCount: 64,
                            itemBuilder: (context, index) {
                               final row = index ~/ 8;
                               final col = index % 8;
                               final isSquareDark = (row + col) % 2 != 0;
                               final isSelected =
                                   _selectedRow == row && _selectedCol == col;
                               final piece = _board[row][col];
                               final canMoveHere = legalTargets.contains(
                                 '$row,$col',
                               );
                               final isLastMove = _isLastMoveCell(row, col);

                               return GestureDetector(
                                 onTap: () => _onCellTap(row, col),
                                 child: Container(
                                   alignment: Alignment.center,
                                   decoration: BoxDecoration(
                                     color: isSelected
                                         ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                                         : canMoveHere
                                         ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                         : isLastMove
                                         ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                                         : (isSquareDark
                                               ? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1))
                                               : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC))),
                                   ),
                                   child: Stack(
                                     alignment: Alignment.center,
                                     children: [
                                       if (canMoveHere && piece.isEmpty)
                                         Container(
                                           width: boardSize / 32,
                                           height: boardSize / 32,
                                           decoration: BoxDecoration(
                                             color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                             shape: BoxShape.circle,
                                           ),
                                         ),
                                       AnimatedScale(
                                         duration: const Duration(milliseconds: 160),
                                         scale: isSelected ? 1.15 : 1.0,
                                         child: Text(
                                           pieceEmojis[piece] ?? '',
                                           style: TextStyle(
                                             fontSize: boardSize / 11,
                                             color: _isWhitePiece(piece)
                                                 ? (isDark ? Colors.white : Colors.white)
                                                 : (isDark ? Colors.black : Colors.black),
                                             shadows: [
                                               Shadow(
                                                 color: Colors.black.withValues(alpha: 0.2),
                                                 offset: const Offset(1, 1),
                                                 blurRadius: 2,
                                               ),
                                             ],
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _HintCard(
                        gameOver: _gameOver,
                        multiplayer: widget.sessionId != null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGameOverDialog(String title, String message, bool isWin, int xp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isWin
                        ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                        : [const Color(0xFF64748B), const Color(0xFF475569)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isWin ? Icons.emoji_events_rounded : Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(_resetGame);
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
                  child: const Text(
                    'Yeniden Oyna',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChessMove {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  const ChessMove(this.fromRow, this.fromCol, this.toRow, this.toCol);
}

class _StatusPanel extends ConsumerWidget {
  final String statusText;
  final bool whiteTurn;
  final bool gameOver;
  final String difficulty;
  final int whitePieces;
  final int blackPieces;

  const _StatusPanel({
    required this.statusText,
    required this.whiteTurn,
    required this.gameOver,
    required this.difficulty,
    required this.whitePieces,
    required this.blackPieces,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (whiteTurn ? Colors.white : const Color(0xFF1E293B)),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  whiteTurn ? '♔' : '♚',
                  style: TextStyle(
                    fontSize: 28,
                    color: whiteTurn ? Colors.black : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameOver
                          ? l10n.translate('match_completed')
                          : (whiteTurn
                              ? l10n.translate('white_turn')
                              : l10n.translate('black_turn')),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  difficulty,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.translate('white'),
                  value: l10n.translate('pieces_count').replaceAll('{count}', whitePieces.toString()),
                  icon: '♔',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: l10n.translate('black'),
                  value: l10n.translate('pieces_count').replaceAll('{count}', blackPieces.toString()),
                  icon: '♚',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w700),
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

class _HintCard extends ConsumerWidget {
  final bool gameOver;
  final bool multiplayer;

  const _HintCard({required this.gameOver, required this.multiplayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: textColor.withValues(alpha: 0.04),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              gameOver
                  ? l10n.translate('chess_hint_game_over')
                  : (multiplayer
                      ? l10n.translate('chess_hint_multiplayer')
                      : l10n.translate('chess_hint_default')),
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
