import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/engine/tamil_engine.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';

/// Controller for managing keyboard state and actions.
class KeyboardController extends ValueNotifier<KeyboardState> {
  final TextEditingController textController;

  KeyboardController({
    required this.textController,
    KeyboardState initialState = const KeyboardState(),
  }) : super(initialState);

  /// Changes the current layout of the keyboard.
  void switchLayout(KeyboardLayout layout) {
    value = value.copyWith(currentLayout: layout);
  }

  /// Toggles the shift state (between lowercase and uppercase English).
  void toggleShift() {
    if (value.currentLayout == KeyboardLayout.english) {
      switchLayout(KeyboardLayout.englishCaps);
    } else if (value.currentLayout == KeyboardLayout.englishCaps) {
      switchLayout(KeyboardLayout.english);
    }
  }

  /// Inserts text at the cursor using the Tamil engine to handle composition.
  /// Without a valid cursor the text is appended, as before.
  void onKeyPress(String character) {
    // Attempt composition if in Tamil mode, else just insert
    _insert(character, compose: value.currentLayout == KeyboardLayout.tamil);

    // For English caps, we sometimes revert to lowercase after first char,
    // but a standard keyboard maintains shift lock if tapped twice.
    // This can be enhanced further based on detailed specs.
  }

  /// Inserts a new line at the cursor.
  void onEnter() => _insert('\n', compose: false);

  /// Inserts a tab character at the cursor.
  void onTab() => _insert('\t', compose: false);

  /// Processes backspace action: deletes the selection, or the character
  /// before the cursor (the last character when there is no cursor).
  void onBackspace() {
    final range = _editRange();
    final text = textController.text;
    final prefix = range.isCollapsed
        ? TamilEngine.processBackspace(text.substring(0, range.start))
        : text.substring(0, range.start);
    _replace(prefix, text.substring(range.end));
  }

  /// Moves the cursor by [delta] characters, collapsing any selection.
  void moveCursor(int delta) {
    final text = textController.text;
    final range = _editRange();
    final from = delta < 0 ? range.start : range.end;
    final offset = range.isCollapsed ? from + delta : from;
    textController.selection =
        TextSelection.collapsed(offset: offset.clamp(0, text.length));
  }

  void _insert(String character, {required bool compose}) {
    final range = _editRange();
    final text = textController.text;
    final before = text.substring(0, range.start);
    final prefix = compose
        ? TamilEngine.processInput(before, character)
        : before + character;
    _replace(prefix, text.substring(range.end));
  }

  /// The range being edited: the current selection, or the end of the text
  /// when the controller has no valid selection.
  TextRange _editRange() {
    final text = textController.text;
    final selection = textController.selection;
    if (!selection.isValid) {
      return TextRange.collapsed(text.length);
    }
    return TextRange(
      start: selection.start.clamp(0, text.length),
      end: selection.end.clamp(0, text.length),
    );
  }

  void _replace(String prefix, String suffix) {
    textController.value = TextEditingValue(
      text: prefix + suffix,
      selection: TextSelection.collapsed(offset: prefix.length),
    );
  }
}
