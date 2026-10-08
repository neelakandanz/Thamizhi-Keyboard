import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_controller.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';

/// Builds [DesktopKeySpec]s wired to the [KeyboardController] and the
/// one-shot Shift state of the desktop keyboard.
class DesktopKeyActions {
  final KeyboardController controller;

  /// Whether the one-shot Shift is engaged for the next key.
  final bool shiftActive;
  final VoidCallback onShift;

  /// Called after every key that consumes the one-shot Shift.
  final VoidCallback onShiftConsumed;

  const DesktopKeyActions({
    required this.controller,
    required this.shiftActive,
    required this.onShift,
    required this.onShiftConsumed,
  });

  /// A key typing [value], or [shifted] while Shift is engaged.
  /// The alternate character is shown as a small hint.
  DesktopKeySpec type(String value, {String? shifted, double units = 1}) {
    final output = shiftActive && shifted != null ? shifted : value;
    return DesktopKeySpec(
      label: output,
      subLabel: shifted == null ? null : (shiftActive ? value : shifted),
      units: units,
      onTap: () => _type(output),
    );
  }

  /// A letter key; uppercase when exactly one of Caps Lock / Shift is on.
  DesktopKeySpec letter(String lower, {required bool capsLock}) {
    final output = capsLock != shiftActive ? lower.toUpperCase() : lower;
    return DesktopKeySpec(label: output, onTap: () => _type(output));
  }

  DesktopKeySpec backspace(double units) => DesktopKeySpec(
        icon: Icons.backspace_outlined,
        units: units,
        style: DesktopKeyStyle.modifier,
        repeat: true,
        semanticLabel: 'Backspace',
        onTap: controller.onBackspace,
      );

  DesktopKeySpec enter(double units) => DesktopKeySpec(
        icon: Icons.keyboard_return,
        label: 'Enter',
        units: units,
        style: DesktopKeyStyle.accent,
        onTap: () {
          controller.onEnter();
          onShiftConsumed();
        },
      );

  DesktopKeySpec tab(double units) => DesktopKeySpec(
        icon: Icons.keyboard_tab,
        label: 'Tab',
        units: units,
        style: DesktopKeyStyle.modifier,
        onTap: () {
          controller.onTab();
          onShiftConsumed();
        },
      );

  DesktopKeySpec shift(double units) => DesktopKeySpec(
        icon: Icons.arrow_upward_rounded,
        label: 'Shift',
        units: units,
        style: DesktopKeyStyle.modifier,
        active: shiftActive,
        onTap: onShift,
      );

  DesktopKeySpec capsLock(double units, {required bool active}) =>
      DesktopKeySpec(
        label: 'Caps',
        units: units,
        style: DesktopKeyStyle.modifier,
        active: active,
        semanticLabel: 'Caps Lock',
        onTap: controller.toggleShift,
      );

  DesktopKeySpec switchTo(String label, KeyboardLayout layout,
          {double units = 1.75}) =>
      DesktopKeySpec(
        label: label,
        units: units,
        style: DesktopKeyStyle.modifier,
        onTap: () {
          onShiftConsumed();
          controller.switchLayout(layout);
        },
      );

  /// The shared bottom row: two layout switches, space bar and arrow keys.
  List<DesktopKeySpec> bottomRow(
    DesktopKeySpec first,
    DesktopKeySpec second, {
    String spaceLabel = 'space',
  }) {
    return [
      first,
      second,
      DesktopKeySpec(
        label: spaceLabel,
        units: 9,
        style: DesktopKeyStyle.space,
        semanticLabel: 'Space',
        onTap: () => _type(' '),
      ),
      DesktopKeySpec(
        icon: Icons.keyboard_arrow_left,
        units: 1.25,
        style: DesktopKeyStyle.modifier,
        repeat: true,
        semanticLabel: 'Cursor left',
        onTap: () => controller.moveCursor(-1),
      ),
      DesktopKeySpec(
        icon: Icons.keyboard_arrow_right,
        units: 1.25,
        style: DesktopKeyStyle.modifier,
        repeat: true,
        semanticLabel: 'Cursor right',
        onTap: () => controller.moveCursor(1),
      ),
    ];
  }

  void _type(String text) {
    controller.onKeyPress(text);
    onShiftConsumed();
  }
}
