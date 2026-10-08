import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_controller.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_keyboard_view.dart';
import 'package:thamizhi_keyboard/src/ui/keyboard_mode.dart';
import 'package:thamizhi_keyboard/src/ui/layouts/english_layout.dart';
import 'package:thamizhi_keyboard/src/ui/layouts/number_layout.dart';
import 'package:thamizhi_keyboard/src/ui/layouts/tamil_layout.dart';
import 'package:thamizhi_keyboard/src/ui/layouts/tamil_number_layout.dart';
import 'package:thamizhi_keyboard/src/ui/theme/keyboard_theme.dart';

/// The main keyboard wrapper that manages responsive constraints and the active layout.
class ThamizhiKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final KeyboardTheme? theme;

  /// Which style to render. [KeyboardMode.auto] (the default) uses the
  /// full-size desktop keyboard on wide desktop / web windows and the compact
  /// keyboard everywhere else.
  final KeyboardMode mode;

  /// Maximum width of the desktop keyboard. The compact keyboard keeps its
  /// 600 px limit.
  final double desktopMaxWidth;

  /// Font family for key labels in desktop mode, e.g. `'Noto Sans Tamil'`.
  final String? fontFamily;

  const ThamizhiKeyboard({
    super.key,
    required this.controller,
    this.theme,
    this.mode = KeyboardMode.auto,
    this.desktopMaxWidth = 1280,
    this.fontFamily,
  });

  @override
  State<ThamizhiKeyboard> createState() => _ThamizhiKeyboardState();
}

class _ThamizhiKeyboardState extends State<ThamizhiKeyboard> {
  late KeyboardController _keyboardController;

  @override
  void initState() {
    super.initState();
    _keyboardController = KeyboardController(textController: widget.controller);
  }

  @override
  void didUpdateWidget(ThamizhiKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final previousState = _keyboardController.value;
      _keyboardController.dispose();
      _keyboardController = KeyboardController(
        textController: widget.controller,
        initialState: previousState,
      );
    }
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine theme dynamically if not provided
    final theme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? KeyboardTheme.dark
            : KeyboardTheme.light);

    return KeyboardThemeData(
      theme: theme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useDesktop = shouldUseDesktopLayout(
            mode: widget.mode,
            availableWidth: constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width,
            platform: Theme.of(context).platform,
            isWeb: kIsWeb,
          );
          if (useDesktop) {
            return DesktopKeyboardView(
              controller: _keyboardController,
              maxWidth: widget.desktopMaxWidth,
              fontFamily: widget.fontFamily,
            );
          }

          // Adjust layout width for larger screens (tablets, web, desktop)
          double keyboardWidth = constraints.maxWidth;
          if (keyboardWidth > 600) {
            keyboardWidth =
                600; // Constrain maximum width to mimic native keyboard bounds
          }

          return Container(
            width: constraints.maxWidth,
            color: theme.backgroundColor,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: keyboardWidth,
              child: SafeArea(
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                  child: ValueListenableBuilder<KeyboardState>(
                    valueListenable: _keyboardController,
                    builder: (context, state, child) {
                      return IntrinsicHeight(
                        child: _buildActiveLayout(state.currentLayout),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveLayout(KeyboardLayout layout) {
    switch (layout) {
      case KeyboardLayout.tamil:
        return TamilLayout(controller: _keyboardController);
      case KeyboardLayout.english:
      case KeyboardLayout.englishCaps:
        return EnglishLayout(controller: _keyboardController);
      case KeyboardLayout.numbers:
      case KeyboardLayout.symbols:
        return NumberLayout(controller: _keyboardController);
      case KeyboardLayout.tamilNumbers:
        return TamilNumberLayout(controller: _keyboardController);
    }
  }
}
