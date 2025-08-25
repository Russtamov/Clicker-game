import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

class AudioService {
  static const List<String> _tapSounds = ['tap1.wav', 'tap2.wav', 'tap3.wav'];
  final Random _random = Random();

  Future<void> initialize() async {
    try {
      FlameAudio.audioCache.prefix = 'assets/sfx/';
      await FlameAudio.audioCache.loadAll(_tapSounds);
    } catch (_) {
      // Audio loading failed, will use fallback
    }
  }

  void playTapSound() {
    try {
      final soundIndex = _random.nextInt(_tapSounds.length);
      final volume = 0.5 + _random.nextDouble() * 0.3;
      FlameAudio.play(_tapSounds[soundIndex], volume: volume);
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
    HapticFeedback.selectionClick();
  }
}
