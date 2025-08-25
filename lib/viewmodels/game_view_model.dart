import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/game_state_model.dart';
import '../models/target_model.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import '../services/leaderboard_service.dart';

class GameViewModel extends ChangeNotifier {
  final LeaderboardService _leaderboardService;
  final GameService _gameService;
  final AudioService _audioService;

  GameStateModel _gameState = GameStateModel(targetPosition: Vector2.zero());

  GameViewModel({
    required LeaderboardService leaderboardService,
    GameService? gameService,
    AudioService? audioService,
  }) : _leaderboardService = leaderboardService,
       _gameService = gameService ?? GameService(),
       _audioService = audioService ?? AudioService();

  // Getters for the View
  GameStateModel get gameState => _gameState;
  int get score => _gameState.score;
  int get bestScore => _gameState.bestScore;
  double get targetScale => _gameState.targetScale;
  Vector2 get targetPosition => _gameState.targetPosition;
  TargetModel get currentTarget =>
      _gameService.getCurrentTarget(_gameState.isFirstTarget);

  Future<void> initializeAudio() async {
    await _audioService.initialize();
  }

  void resetGame(Vector2 gameSize) {
    _gameState = GameStateModel(
      targetPosition: _gameService.generateRandomPosition(gameSize, 80.0),
    );
    notifyListeners();
  }

  void onTargetHit(Vector2 gameSize) {
    _gameState = _gameService.processHit(_gameState, gameSize);
    _audioService.playTapSound();
    notifyListeners();
  }

  void applyRewardDouble() {
    _gameState = _gameState.copyWith(
      score: _gameState.score * 2,
      bestScore: math.max(_gameState.bestScore, _gameState.score * 2),
    );
    notifyListeners();
  }

  Future<void> submitScore() async {
    await _leaderboardService.submitBestScore(_gameState.bestScore);
  }
}
