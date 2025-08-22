# 🏔️ Dash por el Cotopaxi

An endless runner game developed in Flutter + Flame where you control Dash running through Cotopaxi, avoiding obstacles and collecting cacao and roses.



## 🎬 Demo Video

https://github.com/user-attachments/assets/fddcf511-613e-4530-b392-2a1e995aeb53

*Watch the game in action! See Dash running through the beautiful Cotopaxi landscape, avoiding obstacles and collecting items.*





## 🎮 Game Features

- **Genre**: Endless runner with time limit (60 seconds)
- **Objective**: Maximize score by avoiding obstacles and collecting items
- **Controls**: 
  - Single tap: Normal jump
  - Double tap: High jump
  - Swipe down: Slide
- **Mechanics**:
  - Life system (3 hearts)
  - Combo multiplier (x1 to x5)
  - **Smooth progressive difficulty system** (see detailed explanation below)
  - Scoring for collected items and survival time
  - Dynamic obstacle/collectible probability based on game time

## 🚀 Installation and Execution

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- macOS (for native compilation)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dash_cotopaxi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the game**
   ```bash
   # For development
   flutter run -d macos
   
   # For release build
   flutter build macos --release
   ```

## 🏗️ Project Architecture

```
lib/
├── main.dart                 # Entry point and app initialization
├── core/                     # Core configurations and utilities
│   ├── game_config.dart      # Game constants and settings
│   ├── game_strings.dart     # Localized text strings
│   ├── game_types.dart       # Type definitions and enums
│   └── game_utils.dart       # Utility functions and calculations
├── game/                     # Game logic and components
│   ├── cotopaxi_game.dart    # Main game class
│   ├── player.dart           # Player character (Dinosaur)
│   └── components.dart       # Game objects (obstacles, collectibles, etc.)
├── ui/                       # User interface screens
│   ├── home_screen.dart      # Main menu
│   └── game_screen.dart      # Game view wrapper
└── assets/                   # Game resources
    └── images/
        ├── sprites/          # Characters and objects
        │   └── anim/         # Animation spritesheets
        ├── parallax/         # Layered backgrounds (Cotopaxi scenery)
        └── ui/               # Interface elements
```

## 🎯 Main Components

### CotopaxiGame
- Main game class that extends `FlameGame`
- Manages game state (idle, countdown, running, gameOver)
- Coordinates all game systems

### Player (Dinosaur)
- Realistic dinosaur character controlled by the user
- Physics system with gravity and collisions
- High-quality animations: 8-frame running cycle, 12-frame jump sequence
- Precise collision detection with optimized hitboxes
- Smooth animation transitions between running and jumping states

### SpawnManager
- Dynamically generates obstacles and collectibles
- **Smart difficulty progression**: Smooth exponential curve over 60 seconds
- **Adaptive spawn rates**: Frequency decreases from 2.5s to 0.8s intervals
- **Dynamic probability**: Obstacle ratio increases from 40% to 75% over time
- Intelligent spawn timing to maintain optimal challenge level

### Obstacles & Collectibles
- **Obstacles**: Llamas, rocks and puddles (lose lives)
- **Collectibles**: Cacao and roses (increase score)
- Automatic movement from right to left

### HUD (Heads Up Display)
- Remaining time
- Current score
- Remaining lives
- Combo multiplier

## 🎨 Game Assets

### Sprites
- `anim/dino_run.png`: Realistic dinosaur running animation (8 frames, 680x472px each)
- `anim/dino_jump.png`: Realistic dinosaur jump animation (12 frames, 4 rows x 3 columns, 680x472px each)
- `llama.png`, `roca.png`, `charco.png`: Obstacles
- `cacao.png`, `rosa.png`: Collectibles

### Parallax Backgrounds
- `bg_0_sky.png`: Base sky
- `bg_1_clouds.png`: Clouds (layer 1)
- `bg_2_cotopaxi.png`: Cotopaxi mountain (layer 2)
- `bg_3_fields.png`: Fields and prairies (layer 3)

## 🎮 How to Play

1. **Start**: Press "Play (60s)" on the main screen
2. **Countdown**: Wait for the 3, 2, 1 countdown...
3. **Gameplay**: 
   - Tap to jump over obstacles
   - Double tap for high jump
   - Swipe down to avoid llamas
   - Collect cacao and roses for points
4. **Objective**: Survive 60 seconds with the highest possible score

## 🔧 Customization

### Difficulty System
The game features a **smooth progressive difficulty curve** designed for optimal gameplay experience:

#### Spawn Intervals
- **Initial**: 2.5 seconds between spawns (relaxed start)
- **Final**: 0.8 seconds between spawns (maximum intensity)
- **Progression**: Smooth exponential curve over 60 seconds using quadratic easing

#### Obstacle Speed
- **Base speed**: 280 px/s (manageable start)
- **Speed increase**: +4 px/s per second (gradual acceleration)
- **Final speed**: ~520 px/s at 60 seconds

#### Dynamic Obstacle Probability
- **Initial**: 40% obstacles, 60% collectibles (learning phase)
- **Final**: 75% obstacles, 25% collectibles (challenge phase)
- **Progression**: Linear increase based on elapsed time

### Scoring
- Cacao/Rose: +10 points
- Survival time: +5 points/second
- Combo multiplier: x1 to x5

## 📊 Progressive Difficulty System

### Overview
The game implements a sophisticated difficulty system that provides a smooth learning curve, starting easy for new players and gradually increasing to maintain engagement throughout the 60-second gameplay session.

### Technical Implementation

#### 1. Spawn Interval Calculation
```dart
// Smooth exponential curve instead of step-based progression
final difficultyProgress = (elapsedTime / 60.0).clamp(0.0, 1.0);
final easingFactor = 1.0 - pow(1.0 - difficultyProgress, 2.0); // Quadratic easing

final newInterval = GameConfig.spawnInterval - 
    (easingFactor * (GameConfig.spawnInterval - GameConfig.minSpawnInterval));
```

#### 2. Dynamic Obstacle Probability
```dart
const baseObstacleProbability = 0.4;  // 40% at start
const maxObstacleProbability = 0.75;  // 75% at end
final difficultyProgress = (elapsedTime / 60.0).clamp(0.0, 1.0);
final obstacleProbability = baseObstacleProbability + 
    (difficultyProgress * (maxObstacleProbability - baseObstacleProbability));
```

#### 3. Speed Progression
- **Linear increase**: `speed = baseSpeed + (elapsedTime * speedIncrease)`
- Provides predictable acceleration that players can adapt to

### Difficulty Timeline

| Time | Spawn Interval | Obstacle % | Speed (px/s) | Player Experience |
|------|----------------|------------|--------------|-------------------|
| 0s   | 2.5s          | 40%        | 280          | Learning phase    |
| 15s  | ~2.1s         | 49%        | 340          | Warming up        |
| 30s  | ~1.5s         | 58%        | 400          | Getting challenging |
| 45s  | ~1.0s         | 67%        | 460          | Intense gameplay  |
| 60s  | 0.8s          | 75%        | 520          | Maximum difficulty |

### Design Philosophy

1. **Gentle Start**: New players aren't overwhelmed immediately
2. **Smooth Progression**: No sudden difficulty spikes that feel unfair
3. **Maintained Challenge**: Experienced players stay engaged throughout
4. **Balanced Rewards**: More collectibles early help build score foundation
5. **Visual Feedback**: Hitboxes precisely match sprite visuals for fair collisions

### Configuration Constants
Located in `lib/core/game_config.dart`:

```dart
// Spawn settings
static const double spawnInterval = 2.5;      // Initial interval
static const double minSpawnInterval = 0.8;   // Maximum difficulty interval
static const double difficultyIncrease = 0.2; // Progression rate

// Physics
static const double obstacleSpeed = 280.0;     // Starting speed
static const double speedIncrease = 4.0;      // Speed increment per second
```

## 🐛 Troubleshooting

### Common issues
1. **"No issues found"**: Game compiles correctly
2. **Assets not found**: Verify that paths in `pubspec.yaml` are correct
3. **Collisions not working**: Make sure `HasCollisionDetection` is active

### Debug
```bash
# Static analysis
flutter analyze

# Build cleanup
flutter clean
flutter pub get

# Debug build
flutter build macos --debug
```

## 🚧 Upcoming Improvements

- [ ] Audio system with `flame_audio`
- [ ] Local leaderboard with `shared_preferences`
- [ ] Particle effects
- [ ] More obstacle types
- [ ] Power-ups and special abilities
- [ ] Local multiplayer mode
- [ ] Game Center integration

## 📱 Supported Platforms

- ✅ macOS (primary)
- 🔄 iOS (in development)
- 🔄 Android (in development)
- 🔄 Web (future)

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is under the MIT License. See `LICENSE` for more details.

## 🙏 Acknowledgments

- **Flame Engine**: Game engine for Flutter
- **Flutter Team**: Cross-platform UI framework
- **Flutter Community**: For support and resources
- **Cotopaxi**: Inspiration for the game theme

---

**Enjoy running through Cotopaxi! 🏃‍♂️🏔️**
