import 'dart:ui' as ui;
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart' as fe;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../viewmodels/game_view_model.dart';

class ClickerGame extends FlameGame with HasGameReference<ClickerGame> {
  late SpriteComponent target; // public access
  final GameViewModel viewModel;
  late Sprite _sprite1, _sprite2;

  ClickerGame({required this.viewModel});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    // Initialize audio through ViewModel
    await viewModel.initializeAudio();

    // Load target sprites
    await _loadTargetSprites();

    // Create target FIRST
    _createTarget();

    // THEN listen to ViewModel changes
    viewModel.addListener(_onGameStateChanged);

    // FINALLY initialize game state
    viewModel.resetGame(size);
  }

  @override
  void onRemove() {
    viewModel.removeListener(_onGameStateChanged);
    super.onRemove();
  }

  void _onGameStateChanged() {
    // Update target sprite based on current target
    final currentTarget = viewModel.currentTarget;
    target.sprite = currentTarget.spritePath == 'target.png'
        ? _sprite1
        : _sprite2;

    // Update target position and scale
    target.position = viewModel.targetPosition;
    target.scale = Vector2.all(viewModel.targetScale);
  }

  Future<void> _loadTargetSprites() async {
    // Always use circle targets instead of PNG files
    final canvasImage1 = await _generateFallbackCircle(
      const Color(0xFF6366F1), // Primary blue
    );
    _sprite1 = Sprite(canvasImage1);

    final canvasImage2 = await _generateFallbackCircle(
      const Color(0xFFEC4899), // Secondary pink
    );
    _sprite2 = Sprite(canvasImage2);
  }

  void _createTarget() {
    // Start with default position, will be updated by listener
    target = SpriteComponent(sprite: _sprite1, size: Vector2(80, 80))
      ..position =
          Vector2(100, 100) // Default position
      ..anchor = Anchor.topLeft;
    add(target);
  }

  Future<ui.Image> _generateFallbackCircle(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Gradient background circle
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        const ui.Offset(40, 40), // center
        30, // radius
        [
          color.withOpacity(1.0),
          color.withOpacity(0.7),
          color.withOpacity(0.4),
        ],
        [0.0, 0.7, 1.0],
      );
    canvas.drawCircle(const ui.Offset(40, 40), 35, paint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const ui.Offset(40, 40), 35, borderPaint);

    // Inner glow
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(const ui.Offset(40, 40), 32, glowPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(80, 80);
    return img;
  }

  // Hit feedback animation (called from Flutter GestureDetector)
  void playHitAnimation() {
    target.add(
      fe.ScaleEffect.to(Vector2.all(1.2), fe.EffectController(duration: 0.08))
        ..onComplete = () {
          target.add(
            fe.ScaleEffect.to(
              Vector2.all(viewModel.targetScale),
              fe.EffectController(duration: 0.08),
            ),
          );
        },
    );
  }
}
