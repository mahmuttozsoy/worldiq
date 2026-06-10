import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioNotifier extends Notifier<void> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void build() {
    ref.onDispose(() {
      _player.dispose();
    });
  }

  Future<void> playCorrect() async {
    try {
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      // Ignore if file empty or error
    }
  }

  Future<void> playWrong() async {
    try {
      await _player.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      // Ignore if file empty or error
    }
  }

  Future<void> playFinish() async {
    try {
      await _player.play(AssetSource('sounds/finish.mp3'));
    } catch (e) {
      // Ignore
    }
  }
}

final audioProvider = NotifierProvider<AudioNotifier, void>(() {
  return AudioNotifier();
});
