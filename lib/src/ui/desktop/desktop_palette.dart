import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';
import 'package:thamizhi_keyboard/src/ui/theme/keyboard_theme.dart';

/// Colors of the desktop keyboard, resolved from a [KeyboardTheme] with
/// fallbacks for the optional desktop fields.
class DesktopPalette {
  final KeyboardTheme theme;
  final Color accent;
  final Color onAccent;

  const DesktopPalette._(this.theme, this.accent, this.onAccent);

  factory DesktopPalette.resolve(KeyboardTheme theme, ThemeData appTheme) {
    final accent = theme.accentColor ?? appTheme.colorScheme.primary;
    final onAccent =
        accent.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return DesktopPalette._(theme, accent, onAccent);
  }

  bool get _isDark => theme.brightness == Brightness.dark;

  Color get deck => theme.backgroundColor;
  Color get text => theme.textColor;
  Color get subText => theme.textColor.withAlpha(140);
  Color get shadow => theme.shadowColor;
  Color get border => theme.keyBorderColor ?? text.withAlpha(_isDark ? 18 : 24);

  Color fill(DesktopKeyStyle style) {
    switch (style) {
      case DesktopKeyStyle.character:
      case DesktopKeyStyle.space:
        return theme.keyColor;
      case DesktopKeyStyle.modifier:
        return theme.altKeyColor;
      case DesktopKeyStyle.accent:
        return accent;
    }
  }

  Color foreground(DesktopKeyStyle style) =>
      style == DesktopKeyStyle.accent ? onAccent : text;

  Color hover(DesktopKeyStyle style) {
    final base = fill(style);
    if (style == DesktopKeyStyle.accent) {
      return Color.alphaBlend(Colors.white.withAlpha(30), base);
    }
    return theme.hoverColor ?? Color.alphaBlend(text.withAlpha(16), base);
  }

  Color pressed(DesktopKeyStyle style) {
    final overlay = style == DesktopKeyStyle.accent
        ? Colors.black.withAlpha(40)
        : text.withAlpha(36);
    return Color.alphaBlend(overlay, fill(style));
  }

  Color edge(DesktopKeyStyle style) =>
      theme.keyEdgeColor ??
      Color.alphaBlend(
          Colors.black.withAlpha(_isDark ? 110 : 50), fill(style));
}
