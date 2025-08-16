/// Game configuration constants
class GameConfig {
  // Game settings
  static const double gameDuration = 60.0; // seconds
  static const double gravity = 1600.0; // px/s^2
  static const double baseSpeed = 320.0; // px/s

  // Player settings
  static const double playerWidth = 96.0;
  static const double playerHeight = 96.0;
  static const double jumpForce = 620.0;
  static const double highJumpForce = 720.0;

  // Ground settings
  static const double groundHeight = 120.0;

  // Spawn settings
  static const double spawnInterval = 1.2; // seconds
  static const double minSpawnInterval = 0.55; // seconds
  static const double difficultyIncrease = 0.15; // seconds per 10s

  // Scoring
  static const int itemScore = 10;
  static const int survivalScore = 5; // per second
  static const int maxCombo = 99;
  static const int comboThreshold = 5;

  // Physics
  static const double obstacleSpeed = 360.0;
  static const double speedIncrease = 8.0; // px/s per second

  // UI
  static const double hudPadding = 16.0;
  static const double messageFontSize = 18.0;
  static const double scoreFontSize = 24.0;
  static const double comboFontSize = 16.0;

  // Debug settings
  static const bool showHitBoxes = false; // Set to true to see collision boxes
}
