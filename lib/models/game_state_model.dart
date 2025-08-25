import 'package:flame/components.dart';

class GameStateModel {
  final int score;
  final int bestScore;
  final int hitCount;
  final double targetScale;
  final bool isFirstTarget;
  final Vector2 targetPosition;

  const GameStateModel({
    this.score = 0,
    this.bestScore = 0,
    this.hitCount = 0,
    this.targetScale = 1.0,
    this.isFirstTarget = true,
    required this.targetPosition,
  });

  GameStateModel copyWith({
    int? score,
    int? bestScore,
    int? hitCount,
    double? targetScale,
    bool? isFirstTarget,
    Vector2? targetPosition,
  }) {
    return GameStateModel(
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      hitCount: hitCount ?? this.hitCount,
      targetScale: targetScale ?? this.targetScale,
      isFirstTarget: isFirstTarget ?? this.isFirstTarget,
      targetPosition: targetPosition ?? this.targetPosition,
    );
  }
}
