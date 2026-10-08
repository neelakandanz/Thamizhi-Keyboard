import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_controller.dart';
import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';

void main() {
  late TextEditingController textController;
  late KeyboardController keyboardController;

  setUp(() {
    textController = TextEditingController();
    keyboardController = KeyboardController(textController: textController);
  });

  void setText(String text, {int? cursor, int? extent}) {
    textController.value = TextEditingValue(
      text: text,
      selection: cursor == null
          ? const TextSelection.collapsed(offset: -1)
          : TextSelection(
              baseOffset: cursor, extentOffset: extent ?? cursor),
    );
  }

  group('Cursor-aware editing', () {
    test('Without a cursor, typing appends like before', () {
      setText('அம்மா');
      keyboardController.onKeyPress('ள்');
      expect(textController.text, 'அம்மாள்');
      expect(textController.selection.baseOffset, textController.text.length);
    });

    test('Inserts at the cursor', () {
      keyboardController.switchLayout(KeyboardLayout.english);
      setText('Hllo', cursor: 1);
      keyboardController.onKeyPress('e');
      expect(textController.text, 'Hello');
      expect(textController.selection.baseOffset, 2);
    });

    test('Tamil composition happens at the cursor', () {
      setText('க் மலர்', cursor: 2);
      keyboardController.onKeyPress('ஆ');
      expect(textController.text, 'கா மலர்');
      expect(textController.selection.baseOffset, 2);
    });

    test('Typing replaces the selection', () {
      keyboardController.switchLayout(KeyboardLayout.english);
      setText('Hello world', cursor: 6, extent: 11);
      keyboardController.onKeyPress('X');
      expect(textController.text, 'Hello X');
    });

    test('Backspace deletes before the cursor', () {
      setText('abcd', cursor: 2);
      keyboardController.onBackspace();
      expect(textController.text, 'acd');
      expect(textController.selection.baseOffset, 1);
    });

    test('Backspace at the start does nothing', () {
      setText('abcd', cursor: 0);
      keyboardController.onBackspace();
      expect(textController.text, 'abcd');
    });

    test('Backspace deletes the selection', () {
      setText('abcdef', cursor: 1, extent: 4);
      keyboardController.onBackspace();
      expect(textController.text, 'aef');
    });

    test('Enter and Tab insert at the cursor without composition', () {
      setText('க்ப', cursor: 2);
      keyboardController.onEnter();
      expect(textController.text, 'க்\nப');
      keyboardController.onTab();
      expect(textController.text, 'க்\n\tப');
    });

    test('moveCursor moves and clamps', () {
      setText('abc');
      keyboardController.moveCursor(-1);
      expect(textController.selection.baseOffset, 2);
      keyboardController.moveCursor(-5);
      expect(textController.selection.baseOffset, 0);
      keyboardController.moveCursor(10);
      expect(textController.selection.baseOffset, 3);
    });

    test('moveCursor collapses a selection to its edge', () {
      setText('abcdef', cursor: 1, extent: 4);
      keyboardController.moveCursor(-1);
      expect(textController.selection, const TextSelection.collapsed(offset: 1));
      setText('abcdef', cursor: 1, extent: 4);
      keyboardController.moveCursor(1);
      expect(textController.selection, const TextSelection.collapsed(offset: 4));
    });
  });
}
