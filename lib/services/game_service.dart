import 'dart:math';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/target_model.dart';
import '../models/game_state_model.dart';

class GameService {
  static const List<TargetModel> _targets = [
    TargetModel(spritePath: 'target.png', fallbackColor: Color(0xFFE91E63)),
    TargetModel(spritePath: 'target2.png', fallbackColor: Color(0xFF4CAF50)),
  ];

  static const int _maxHitsPerTarget = 20;
  static const double _shrinkRatePerHit = 0.045;
  static const double _minScale = 0.1;

  List<TargetModel> get targets => _targets;

  Vector2 generateRandomPosition(Vector2 gameSize, double targetSize) {
    final random = Random();
    final margin = 10.0; // Daha az margin

    // Herhangi bir yerde çıkabilir - kısıtlama yok!
    final x =
        margin + random.nextDouble() * (gameSize.x - targetSize - margin * 2);
    final y =
        margin + random.nextDouble() * (gameSize.y - targetSize - margin * 2);

    return Vector2(x, y);
  }

  GameStateModel processHit(GameStateModel currentState, Vector2 gameSize) {
    final newHitCount = currentState.hitCount + 1;
    final hitsInCurrentCycle = newHitCount % _maxHitsPerTarget;

    // Calculate new scale
    double newScale = 1.0 - (hitsInCurrentCycle * _shrinkRatePerHit);
    if (newScale < _minScale) newScale = _minScale;

    // Check if we need to switch targets
    bool shouldSwitchTarget = newHitCount % _maxHitsPerTarget == 0;
    bool newIsFirstTarget = shouldSwitchTarget
        ? !currentState.isFirstTarget
        : currentState.isFirstTarget;

    // Reset scale if switching targets
    if (shouldSwitchTarget) {
      newScale = 1.0;
    }

    return currentState.copyWith(
      score: currentState.score + 1,
      bestScore: math.max(currentState.bestScore, currentState.score + 1),
      hitCount: newHitCount,
      targetScale: newScale,
      isFirstTarget: newIsFirstTarget,
      targetPosition: generateRandomPosition(gameSize, _targets[0].size),
    );
  }

  TargetModel getCurrentTarget(bool isFirstTarget) {
    return isFirstTarget ? _targets[0] : _targets[1];
  }
}
