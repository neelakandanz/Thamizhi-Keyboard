import 'package:flutter/widgets.dart';

/// Visual role of a desktop key.
enum DesktopKeyStyle {
  /// A key that types a letter, digit or symbol.
  character,

  /// Shift, Tab, Backspace, layout switches, arrows.
  modifier,

  /// The highlighted primary action (Enter).
  accent,

  /// The space bar; its label is drawn faintly.
  space,
}

/// Describes one key of a desktop layout row.
class DesktopKeySpec {
  final String? label;

  /// Small hint drawn in the top-left corner (e.g. the shifted character).
  final String? subLabel;
  final IconData? icon;

  /// Width in key units; every row of a layout adds up to 15.
  final double units;
  final DesktopKeyStyle style;

  /// Whether a toggle key (Shift, Caps) is currently engaged.
  final bool active;

  /// Whether the action repeats while the key is held down.
  final bool repeat;
  final String? semanticLabel;
  final VoidCallback onTap;

  const DesktopKeySpec({
    this.label,
    this.subLabel,
    this.icon,
    this.units = 1,
    this.style = DesktopKeyStyle.character,
    this.active = false,
    this.repeat = false,
    this.semanticLabel,
    required this.onTap,
  }) : assert(label != null || icon != null,
            'A DesktopKeySpec must have either a label or an icon');
}
