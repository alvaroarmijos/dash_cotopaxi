import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/game_config.dart';
import 'components.dart';
import 'cotopaxi_game.dart';

/// Player character (Dash) component
class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CotopaxiGame> {
  final Vector2 velocity = Vector2.zero();
  bool isOnGround = true;

  late SpriteAnimation _runAnimation;
  late SpriteAnimation _jumpAnimation;

  @override
  Future<void> onLoad() async {
    _runAnimation = await game.loadSpriteAnimation(
      'sprites/anim/dino_run.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.12, // Slightly slower for more realistic running
        textureSize: Vector2(680, 472),
      ),
    );

    _jumpAnimation = await game.loadSpriteAnimation(
      'sprites/anim/dino_jump.png',
      SpriteAnimationData.sequenced(
        amount: 12,
        amountPerRow: 3,
        stepTime: 0.1, // Slightly slower for more realistic jump sequence
        textureSize: Vector2(680, 472),
        loop: false, // Jump animation should not loop
      ),
    );

    animation = _runAnimation;

    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight);
    anchor = Anchor.center;

    // Add custom hitBox for collisions (compensating for image padding)
    // The actual dinosaur is smaller than the full sprite size and positioned more to the left
    add(
      RectangleHitbox(
          size: Vector2(
            GameConfig.playerWidth * 0.3,
            GameConfig.playerHeight * 0.7,
          ), // Smaller hitbox
          position: Vector2(
            GameConfig.playerWidth * 0.1,
            GameConfig.playerHeight * 0.1,
          ), // Offset to match visual dino position
        )
        ..collisionType = CollisionType.active
        ..renderShape = GameConfig.showHitBoxes,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocity.y += GameConfig.gravity * dt;
    position += velocity * dt;

    // Check if on ground
    final groundY = game.size.y - game.ground.height - height / 2;
    if (y >= groundY) {
      y = groundY;
      velocity.y = 0;
      isOnGround = true;

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
    if (isOnGround) {
      velocity.y = stronger ? -GameConfig.highJumpForce : -GameConfig.jumpForce;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Obstacle) {
      game.hit();
      // Temporary invulnerability effect
      opacity = 0.5;
      Future.delayed(const Duration(milliseconds: 1000), () {
        opacity = 1.0;
      });
    } else if (other is Collectible) {
      other.removeFromParent();
      game.addScore(GameConfig.itemScore);
    }
  }
}
