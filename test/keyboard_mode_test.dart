import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thamizhi_keyboard/src/ui/keyboard_mode.dart';

void main() {
  bool resolve(KeyboardMode mode, double width, TargetPlatform platform,
          {bool isWeb = false}) =>
      shouldUseDesktopLayout(
        mode: mode,
        availableWidth: width,
        platform: platform,
        isWeb: isWeb,
      );

  group('shouldUseDesktopLayout', () {
    test('compact never uses desktop', () {
      for (final platform in TargetPlatform.values) {
        expect(resolve(KeyboardMode.compact, 1920, platform), isFalse);
      }
    });

    test('desktop always uses desktop', () {
      for (final platform in TargetPlatform.values) {
        expect(resolve(KeyboardMode.desktop, 320, platform), isTrue);
      }
    });

    test('auto uses desktop on wide desktop platforms', () {
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      ]) {
        expect(resolve(KeyboardMode.auto, kDesktopKeyboardBreakpoint, platform),
            isTrue);
        expect(resolve(KeyboardMode.auto, 839, platform), isFalse);
      }
    });

    test('auto keeps touch platforms compact', () {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.fuchsia,
      ]) {
        expect(resolve(KeyboardMode.auto, 1920, platform), isFalse);
      }
    });

    test('auto uses desktop on wide web', () {
      expect(
          resolve(KeyboardMode.auto, 1280, TargetPlatform.android, isWeb: true),
          isTrue);
      expect(
          resolve(KeyboardMode.auto, 400, TargetPlatform.android, isWeb: true),
          isFalse);
    });
  });
}
