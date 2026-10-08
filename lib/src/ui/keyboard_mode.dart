import 'package:flutter/foundation.dart';

/// Controls which visual style [ThamizhiKeyboard] renders.
enum KeyboardMode {
  /// Desktop style on wide desktop / web windows, compact everywhere else.
  auto,

  /// The original mobile-style keyboard on every platform.
  compact,

  /// The full-size, physical-keyboard style layout.
  desktop,
}

/// Minimum available width (logical pixels) for [KeyboardMode.auto] to pick
/// the desktop layout. Matches the Material "expanded" window size class.
const double kDesktopKeyboardBreakpoint = 840;

/// Resolves whether the desktop layout should be used.
///
/// [KeyboardMode.auto] picks desktop only on desktop platforms (or the web)
/// when at least [kDesktopKeyboardBreakpoint] pixels are available, so a
/// narrow side panel on desktop still gets the compact keyboard.
bool shouldUseDesktopLayout({
  required KeyboardMode mode,
  required double availableWidth,
  required TargetPlatform platform,
  bool isWeb = kIsWeb,
}) {
  switch (mode) {
    case KeyboardMode.compact:
      return false;
    case KeyboardMode.desktop:
      return true;
    case KeyboardMode.auto:
      final isDesktopPlatform = isWeb ||
          platform == TargetPlatform.windows ||
          platform == TargetPlatform.macOS ||
          platform == TargetPlatform.linux;
      return isDesktopPlatform && availableWidth >= kDesktopKeyboardBreakpoint;
  }
}
