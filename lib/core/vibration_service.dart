import 'package:flutter/services.dart';

import 'game_config.dart';

/// Service to handle device vibration/haptic feedback
class VibrationService {
  static bool _initialized = false;

  /// Initialize the vibration service
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Check if vibration is available and enabled
  static bool get isAvailable => GameConfig.enableVibration;

  /// Vibrate for collision with obstacles
  static void collisionVibration() {
    if (!isAvailable) return;

    try {
      // Use heavy impact for stronger feel, but we can't control duration with HapticFeedback
      HapticFeedback.heavyImpact();
      // Note: HapticFeedback duration is fixed by the system, not configurable
    } catch (e) {
      // Silently ignore vibration errors
    }
  }

  /// Vibrate for strong impacts (like game over)
  static void strongVibration() {
    if (!isAvailable) return;

    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently ignore vibration errors
    }
  }

  /// Quick vibration for UI feedback
  static void lightVibration() {
    if (!isAvailable) return;

    try {
      HapticFeedback.lightImpact();
    } catch (e) {
      // Silently ignore vibration errors
    }
  }

  /// Pattern vibration (for special events)
  static void patternVibration() {
    if (!isAvailable) return;

    try {
      // Use selection click for special events
      HapticFeedback.selectionClick();
    } catch (e) {
      // Silently ignore vibration errors
    }
  }
}
