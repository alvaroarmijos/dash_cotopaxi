/// Game state enumeration
enum PlayState { idle, countdown, running, gameOver }

/// Obstacle types
enum ObstacleType { llama, roca, charco }

/// Collectible types
enum CollectibleType { cacao, rosa }

/// Game result data
class GameResult {
  final int score;
  final int lives;
  final double timeSurvived;

  const GameResult({
    required this.score,
    required this.lives,
    required this.timeSurvived,
  });
}

/// Callback types
typedef GameOverCallback = void Function(GameResult result);
typedef SpawnCallback = void Function(dynamic component);
