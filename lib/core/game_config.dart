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
  static const double doubleJumpForce =
      500.0; // pixels per second - slightly less than normal jump
  static const int maxJumps =
      2; // Maximum number of jumps (1 = single jump, 2 = double jump)
  static const double invulnerabilityDuration =
      1.5; // seconds - prevents multiple hits

  // Ground settings
  static const double groundHeight = 80.0;

  // Spawn settings
  static const double spawnInterval =
      2.5; // seconds - Start slower for easier beginning
  static const double minSpawnInterval =
      0.8; // seconds - Minimum interval for maximum difficulty
  static const double difficultyIncrease =
      0.2; // seconds per 10s - More gradual progression

  // Scoring
  static const int itemScore = 10;
  static const int survivalScore = 5; // per second
  static const int maxCombo = 99;
  static const int comboThreshold = 5;

  // Physics
  static const double obstacleSpeed = 280.0; // Start slower
  static const double speedIncrease =
      4.0; // px/s per second - More gradual speed increase

  // UI
  static const double hudPadding = 16.0;
  static const double messageFontSize = 18.0;
  static const double scoreFontSize = 24.0;
  static const double comboFontSize = 16.0;

  // Input settings
  static const bool enableKeyboardControls = true; // Keyboard support
  static const bool enableGamepadControls = true; // Gamepad/controller support

  // Vibration settings
  static const bool enableVibration = true; // Enable haptic feedback
  static const int collisionVibrationDuration =
      800; // milliseconds - stronger vibration on collision
  static const int strongVibrationDuration =
      1000; // milliseconds - very strong vibration for game over

  // Debug settings
  static const bool showHitBoxes = false; // Set to true to see collision boxes
  static const bool debugKeyboardInput = true; // Show keyboard input debug info
}
