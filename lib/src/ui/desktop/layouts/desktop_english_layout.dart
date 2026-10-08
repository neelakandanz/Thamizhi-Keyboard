import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_actions.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';

/// A standard full-size QWERTY layout with number row and shifted symbols.
List<List<DesktopKeySpec>> buildDesktopEnglishRows(
  DesktopKeyActions a, {
  required bool capsLock,
}) {
  DesktopKeySpec letter(String l) => a.letter(l, capsLock: capsLock);

  return [
    [
      a.type('`', shifted: '~'),
      a.type('1', shifted: '!'),
      a.type('2', shifted: '@'),
      a.type('3', shifted: '#'),
      a.type('4', shifted: '\$'),
      a.type('5', shifted: '%'),
      a.type('6', shifted: '^'),
      a.type('7', shifted: '&'),
      a.type('8', shifted: '*'),
      a.type('9', shifted: '('),
      a.type('0', shifted: ')'),
      a.type('-', shifted: '_'),
      a.type('=', shifted: '+'),
      a.backspace(2),
    ],
    [
      a.tab(1.5),
      ...'qwertyuiop'.split('').map(letter),
      a.type('[', shifted: '{'),
      a.type(']', shifted: '}'),
      a.type('\\', shifted: '|', units: 1.5),
    ],
    [
      a.capsLock(1.75, active: capsLock),
      ...'asdfghjkl'.split('').map(letter),
      a.type(';', shifted: ':'),
      a.type('\'', shifted: '"'),
      a.enter(2.25),
    ],
    [
      a.shift(2.25),
      ...'zxcvbnm'.split('').map(letter),
      a.type(',', shifted: '<'),
      a.type('.', shifted: '>'),
      a.type('/', shifted: '?'),
      a.shift(2.75),
    ],
    a.bottomRow(
      a.switchTo('தமிழ்', KeyboardLayout.tamil),
      a.switchTo('123', KeyboardLayout.numbers),
      spaceLabel: 'English',
    ),
  ];
}
