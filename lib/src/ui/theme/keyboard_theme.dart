import 'package:flutter/material.dart';

/// Defines the theme data for the keyboard.
class KeyboardTheme {
  final Color backgroundColor;
  final Color keyColor;
  final Color altKeyColor;
  final Color textColor;
  final Color shadowColor;
  final Brightness brightness;

  /// Highlight color for Enter and engaged Shift / Caps keys (desktop mode).
  /// Falls back to the app's `ColorScheme.primary` when null.
  final Color? accentColor;

  /// Key fill while hovered with a mouse (desktop mode).
  /// Derived from [keyColor] / [altKeyColor] when null.
  final Color? hoverColor;

  /// Thin border drawn around each keycap (desktop mode).
  /// Derived from [textColor] when null.
  final Color? keyBorderColor;

  /// The darker "lip" under each keycap that gives it depth (desktop mode).
  /// Derived from the key fill when null.
  final Color? keyEdgeColor;

  const KeyboardTheme({
    required this.backgroundColor,
    required this.keyColor,
    required this.altKeyColor,
    required this.textColor,
    required this.shadowColor,
    required this.brightness,
    this.accentColor,
    this.hoverColor,
    this.keyBorderColor,
    this.keyEdgeColor,
  });

  /// Creates a copy of this theme with the given fields replaced.
  KeyboardTheme copyWith({
    Color? backgroundColor,
    Color? keyColor,
    Color? altKeyColor,
    Color? textColor,
    Color? shadowColor,
    Brightness? brightness,
    Color? accentColor,
    Color? hoverColor,
    Color? keyBorderColor,
    Color? keyEdgeColor,
  }) {
    return KeyboardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      keyColor: keyColor ?? this.keyColor,
      altKeyColor: altKeyColor ?? this.altKeyColor,
      textColor: textColor ?? this.textColor,
      shadowColor: shadowColor ?? this.shadowColor,
      brightness: brightness ?? this.brightness,
      accentColor: accentColor ?? this.accentColor,
      hoverColor: hoverColor ?? this.hoverColor,
      keyBorderColor: keyBorderColor ?? this.keyBorderColor,
      keyEdgeColor: keyEdgeColor ?? this.keyEdgeColor,
    );
  }

  /// A modern light theme resembling iOS/Gboard light mode.
  static const KeyboardTheme light = KeyboardTheme(
    backgroundColor: Color(0xFFD1D5DB), // Light grey background
    keyColor: Color(0xFFFFFFFF), // White keys
    altKeyColor: Color(0xFFB4BBC9), // Special keys (shift, backspace)
    textColor: Color(0xFF000000), // Black text
    shadowColor: Color(0x40000000),
    brightness: Brightness.light,
  );

  /// A modern dark theme resembling iOS/Gboard dark mode.
  static const KeyboardTheme dark = KeyboardTheme(
    backgroundColor: Color(0xFF2B2B2B), // Dark background
    keyColor: Color(0xFF4A4A4A), // Dark grey keys
    altKeyColor: Color(0xFF383838), // Special keys
    textColor: Color(0xFFFFFFFF), // White text
    shadowColor: Color(0x60000000),
    brightness: Brightness.dark,
  );
}

/// An InheritedWidget to provide the current [KeyboardTheme] to descendants.
class KeyboardThemeData extends InheritedWidget {
  final KeyboardTheme theme;

  const KeyboardThemeData({
    super.key,
    required this.theme,
    required super.child,
  });

  static KeyboardTheme of(BuildContext context) {
    final KeyboardThemeData? result =
        context.dependOnInheritedWidgetOfExactType<KeyboardThemeData>();
    return result?.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? KeyboardTheme.dark
            : KeyboardTheme.light);
  }

  @override
  bool updateShouldNotify(KeyboardThemeData oldWidget) =>
      theme != oldWidget.theme;
}
