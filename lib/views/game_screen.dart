import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/clicker_game.dart';
import '../viewmodels/game_view_model.dart';

class GameScreen extends StatefulWidget {
  final GameViewModel viewModel;
  const GameScreen({super.key, required this.viewModel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ClickerGame _game;

  @override
  void initState() {
    super.initState();
    _game = ClickerGame(viewModel: widget.viewModel);
    // Don't reset here - let the game initialize first
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              Colors.black,
            ],
          ),
        ),
        child: GestureDetector(
          onTapUp: (TapUpDetails details) {
            final localPos = details.localPosition;
            final target = _game.target;

            // Circle hit detection (more precise for round targets)
            final targetCenterX =
                target.position.x + (target.size.x * target.scale.x) / 2;
            final targetCenterY =
                target.position.y + (target.size.y * target.scale.y) / 2;
            final targetRadius = (target.size.x * target.scale.x) / 2;

            final tapX = localPos.dx;
            final tapY = localPos.dy;

            // Distance from tap to circle center
            final distance = math.sqrt(
              (tapX - targetCenterX) * (tapX - targetCenterX) +
                  (tapY - targetCenterY) * (tapY - targetCenterY),
            );

            bool hit = distance <= targetRadius;

            if (hit) {
              widget.viewModel.onTargetHit(Vector2(360, 640));
              _game.playHitAnimation();
            }
          },
          child: Stack(
            children: [
              // Game area
              GameWidget(game: _game),
              // Particle effect overlay
              Positioned.fill(
                child: IgnorePointer(child: _buildParticleEffect()),
              ),
              // HUD Elements - make them pointer transparent
              Positioned.fill(
                child: IgnorePointer(child: _buildScoreOverlay()),
              ),
              _buildCloseButton(),
              Positioned.fill(child: IgnorePointer(child: _buildGameStats())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (_, __) =>
          CustomPaint(painter: ParticleEffectPainter(widget.viewModel.score)),
    );
  }

  Widget _buildScoreOverlay() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.9),
                const Color(0xFFEC4899).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: AnimatedBuilder(
            animation: widget.viewModel,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCORE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                      '${widget.viewModel.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    )
                    .animate(key: ValueKey(widget.viewModel.score))
                    .scale(duration: 200.ms)
                    .then()
                    .shimmer(duration: 300.ms, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameStats() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: AnimatedBuilder(
            animation: widget.viewModel,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: const Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Best: ${widget.viewModel.bestScore}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      color: Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hits: ${widget.viewModel.gameState.hitCount}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class ParticleEffectPainter extends CustomPainter {
  final int score;
  ParticleEffectPainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    if (score == 0) return;

    final paint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Simple particle effect based on score
    for (int i = 0; i < (score % 10); i++) {
      final x = size.width * (0.1 + (i * 0.1));
      final y = size.height * 0.8;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
