import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_controller.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_actions.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_metrics.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_palette.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/layouts/desktop_english_layout.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/layouts/desktop_symbol_layout.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/layouts/desktop_tamil_layout.dart';
import 'package:thamizhi_keyboard/src/ui/theme/keyboard_theme.dart';

/// The full-size, physical-keyboard style keyboard used in desktop mode.
///
/// Shares the [KeyboardController] (and so the Tamil engine) with the
/// compact keyboard; only the presentation differs.
class DesktopKeyboardView extends StatefulWidget {
  final KeyboardController controller;
  final double maxWidth;
  final String? fontFamily;

  const DesktopKeyboardView({
    super.key,
    required this.controller,
    this.maxWidth = 1280,
    this.fontFamily,
  });

  static const double horizontalPadding = 16;

  @override
  State<DesktopKeyboardView> createState() => _DesktopKeyboardViewState();
}

class _DesktopKeyboardViewState extends State<DesktopKeyboardView> {
  /// One-shot Shift: applies to the next key, then releases.
  bool _shift = false;

  void _toggleShift() => setState(() => _shift = !_shift);

  void _consumeShift() {
    if (_shift && mounted) setState(() => _shift = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        DesktopPalette.resolve(KeyboardThemeData.of(context), Theme.of(context));

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = math.min(constraints.maxWidth, widget.maxWidth) -
            DesktopKeyboardView.horizontalPadding * 2;
        final metrics = DesktopMetrics.fromWidth(available);

        return Container(
          width: constraints.maxWidth,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: palette.deck,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesktopKeyboardView.horizontalPadding,
                12,
                DesktopKeyboardView.horizontalPadding,
                14,
              ),
              child: ValueListenableBuilder<KeyboardState>(
                valueListenable: widget.controller,
                builder: (context, state, child) {
                  final rows = _rowsFor(
                    state.currentLayout,
                    DesktopKeyActions(
                      controller: widget.controller,
                      shiftActive: _shift,
                      onShift: _toggleShift,
                      onShiftConsumed: _consumeShift,
                    ),
                  );
                  assert(_rowsAreFullWidth(rows),
                      'Every desktop row must be ${DesktopMetrics.rowUnits} units wide');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final row in rows)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final spec in row)
                              DesktopKey(
                                spec: spec,
                                metrics: metrics,
                                palette: palette,
                                fontFamily: widget.fontFamily,
                              ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<List<DesktopKeySpec>> _rowsFor(
      KeyboardLayout layout, DesktopKeyActions actions) {
    switch (layout) {
      case KeyboardLayout.tamil:
        return buildDesktopTamilRows(actions);
      case KeyboardLayout.english:
      case KeyboardLayout.englishCaps:
        return buildDesktopEnglishRows(actions,
            capsLock: layout == KeyboardLayout.englishCaps);
      case KeyboardLayout.numbers:
      case KeyboardLayout.symbols:
        return buildDesktopSymbolRows(actions, tamilNumerals: false);
      case KeyboardLayout.tamilNumbers:
        return buildDesktopSymbolRows(actions, tamilNumerals: true);
    }
  }

  bool _rowsAreFullWidth(List<List<DesktopKeySpec>> rows) => rows.every((row) =>
      row.fold<double>(0, (sum, spec) => sum + spec.units) ==
      DesktopMetrics.rowUnits);
}
