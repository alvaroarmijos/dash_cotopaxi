import 'dart:math' as dart_math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/game_config.dart';
import 'components.dart';
import 'cotopaxi_game.dart';

/// Player character (Dinosaur) component
class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  final Vector2 velocity = Vector2.zero();
  bool isOnGround = true;
  int jumpCount = 0; // Track number of jumps performed

  // Horizontal movement
  double horizontalSpeed = 0.0;
  static const double maxHorizontalSpeed =
      400.0; // pixels per second - doubled for visibility
  static const double horizontalAcceleration =
      1600.0; // pixels per second squared - doubled
  static const double horizontalDeceleration =
      1200.0; // pixels per second squared - doubled

  // Invulnerability system
  bool isInvulnerable = false;
  double invulnerabilityTimer = 0.0;

  late SpriteAnimation _runAnimation;
  late SpriteAnimation _jumpAnimation;

  @override
  Future<void> onLoad() async {
    /// Dash run sprite
    _runAnimation = await game.loadSpriteAnimation(
      'sprites/anim/dash_run.png',
      SpriteAnimationData.sequenced(
        amount: 16,
        amountPerRow: 4,
        stepTime: 0.1, // Slightly slower for more realistic running
        textureSize: Vector2(240, 255),
      ),
    );

    _jumpAnimation = await game.loadSpriteAnimation(
      'sprites/anim/dash_jump.png',
      SpriteAnimationData.sequenced(
        amount: 16,
        amountPerRow: 4,
        stepTime: 0.1, // Slightly slower for more realistic jump sequence
        textureSize: Vector2(252, 256),
        loop: false, // Jump animation should not loop
      ),
    );

    animation = _runAnimation;

    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight);
    anchor = Anchor.center;

    // Add custom hitBox for collisions (compensating for image padding)
    // The actual dash is smaller than the full sprite size and positioned more to the left
    add(
      RectangleHitbox(
          size: Vector2(
            GameConfig.playerWidth * 0.4,
            GameConfig.playerHeight * 0.7,
          ), // Smaller hitbox
          position: Vector2(
            GameConfig.playerWidth * 0.3,
            GameConfig.playerHeight * 0.1,
          ), // Offset to match visual position
        )
        ..collisionType = CollisionType.active
        ..renderShape = GameConfig.showHitBoxes,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update invulnerability timer
    if (isInvulnerable) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0) {
        isInvulnerable = false;
        opacity = 1.0; // Restore full opacity
      } else {
        // Blinking effect during invulnerability
        opacity =
            0.3 + 0.4 * (1 + dart_math.sin(invulnerabilityTimer * 15)) / 2;
      }
    }

    // Apply gravity
    velocity.y += GameConfig.gravity * dt;

    // Horizontal movement is now controlled directly by key events
    // No gradual deceleration needed

    // Apply velocities to position
    velocity.x = horizontalSpeed;
    position += velocity * dt;

    // Keep player within screen boundaries
    final leftBoundary = width / 2;
    final rightBoundary = game.size.x - width / 2;
    if (x < leftBoundary) {
      x = leftBoundary;
      horizontalSpeed = 0;
    } else if (x > rightBoundary) {
      x = rightBoundary;
      horizontalSpeed = 0;
    }

    // Check if on ground
    final groundY = game.size.y - game.ground.height - height / 2;
    if (y >= groundY) {
      y = groundY;
      velocity.y = 0;
      isOnGround = true;
      jumpCount = 0; // Reset jump count when touching ground

      // Switch to running animation when on ground
      if (animation != _runAnimation) {
        animation = _runAnimation;
      }
    } else {
      isOnGround = false;

      // Switch to jump animation when in air
      if (animation != _jumpAnimation) {
        animation = _jumpAnimation;
      }
    }
  }

  void jump({bool stronger = false}) {
    // Check if we can still jump (either on ground or haven't used all air jumps)
    if (jumpCount < GameConfig.maxJumps) {
      if (jumpCount == 0) {
        // First jump (normal or high jump)
        velocity.y = stronger
            ? -GameConfig.highJumpForce
            : -GameConfig.jumpForce;
      } else {
        // Second jump (double jump) - always uses double jump force
        velocity.y = -GameConfig.doubleJumpForce;
      }

      jumpCount++;

      // Switch to jump animation
      if (animation != _jumpAnimation) {
        animation = _jumpAnimation;
      }
    }
  }

  /// Set player to move left
  void startMoveLeft() {
    horizontalSpeed = -maxHorizontalSpeed;
  }

  /// Set player to move right
  void startMoveRight() {
    horizontalSpeed = maxHorizontalSpeed;
  }

  /// Stop horizontal movement
  void stopMovement() {
    horizontalSpeed = 0.0;
  }

  /// Stop horizontal movement gradually
  void stopHorizontalMovement() {
    // Deceleration is handled in update() method
  }

  /// Reset player state (useful for game restart)
  void reset() {
    isInvulnerable = false;
    invulnerabilityTimer = 0.0;
    opacity = 1.0;
    velocity.setZero();
    horizontalSpeed = 0.0;
    jumpCount = 0; // Reset jump count
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Obstacle && !isInvulnerable) {
      // Only take damage if not currently invulnerable
      game.hit();

      // Activate invulnerability period
      isInvulnerable = true;
      invulnerabilityTimer = GameConfig.invulnerabilityDuration;
    } else if (other is Collectible) {
      other.removeFromParent();
      game.addScore(GameConfig.itemScore);
    }
  }
}
