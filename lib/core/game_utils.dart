import 'dart:math';

import 'package:flame/components.dart';

import 'game_config.dart';

/// Game utility functions
class GameUtils {
  static final Random _random = Random();

  /// Calculate spawn interval based on elapsed time with smooth difficulty curve
  static double calculateSpawnInterval(double elapsedTime) {
    // Smooth exponential difficulty curve instead of step-based
    final difficultyProgress = (elapsedTime / 60.0).clamp(
      0.0,
      1.0,
    ); // Progress over 60 seconds
    final easingFactor =
        1.0 - pow(1.0 - difficultyProgress, 2.0); // Quadratic easing

    final newInterval =
        GameConfig.spawnInterval -
        (easingFactor *
            (GameConfig.spawnInterval - GameConfig.minSpawnInterval));

    return newInterval.clamp(
      GameConfig.minSpawnInterval,
      GameConfig.spawnInterval,
    );
  }

  /// Calculate obstacle speed based on elapsed time
  static double calculateObstacleSpeed(double elapsedTime) {
    return GameConfig.baseSpeed + (elapsedTime * GameConfig.speedIncrease);
  }

  /// Calculate combo multiplier
  static int calculateComboMultiplier(int combo) {
    return (1 + (combo ~/ GameConfig.comboThreshold)).clamp(1, 5);
  }

  /// Format time in MM:SS format
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Get random boolean with given probability
  static bool randomBool(double probability) {
    return _random.nextDouble() < probability;
  }

  /// Get random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Get random double between min and max
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  /// Calculate distance between two points
  static double distance(Vector2 a, Vector2 b) {
    return (a - b).length;
  }

  /// Check if two rectangles overlap
  static bool rectanglesOverlap(
    Vector2 pos1,
    Vector2 size1,
    Vector2 pos2,
    Vector2 size2,
  ) {
    return pos1.x < pos2.x + size2.x &&
        pos1.x + size1.x > pos2.x &&
        pos1.y < pos2.y + size2.y &&
        pos1.y + size1.y > pos2.y;
  }
}
