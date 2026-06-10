import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider((ref) => SoundService());

class SoundService {
  Future<void> _playSound(String path) async {
    try {
      final player = AudioPlayer();
      await player.play(
        AssetSource(path),
      );
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Sound Error ($path): $e');
    }
  }

  // General Sounds
  Future<void> playCorrect() => _playSound('assets/sounds/correct.mp3');
  Future<void> playWrong() => _playSound('assets/sounds/wrong.mp3');
  Future<void> playFinish() => _playSound('assets/sounds/finish.mp3');

  // Chess Specific Sounds
  Future<void> playChessMove() => _playSound('assets/sounds/chess_move.mp3');
  Future<void> playChessCapture() => _playSound('assets/sounds/chess_capture.mp3');

  // Sudoku/UI Sounds
  Future<void> playClick() => _playSound('assets/sounds/click.mp3');

  // Aliases/Contextual methods
  Future<void> playMove() => playChessMove();
  Future<void> playError() => playWrong();
  Future<void> playWin() => playFinish();

  // Play remote audio pronunciations
  Future<void> playRemote(String url) async {
    try {
      final player = AudioPlayer();
      await player.play(
        UrlSource(url),
      );
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Sound Error ($url): $e');
    }
  }
}
