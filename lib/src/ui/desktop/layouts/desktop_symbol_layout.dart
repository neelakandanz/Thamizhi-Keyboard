import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_actions.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';

const _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
const _tamilDigits = ['௧', '௨', '௩', '௪', '௫', '௬', '௭', '௮', '௯', '௦'];

/// Numbers and symbols. [tamilNumerals] shows ௧..௦ instead of 1..0.
List<List<DesktopKeySpec>> buildDesktopSymbolRows(
  DesktopKeyActions a, {
  required bool tamilNumerals,
}) {
  DesktopKeySpec numeralToggle(double units) => tamilNumerals
      ? a.switchTo('123', KeyboardLayout.numbers, units: units)
      : a.switchTo('௧௨௩', KeyboardLayout.tamilNumbers, units: units);

  return [
    [
      ...(tamilNumerals ? _tamilDigits : _digits).map(a.type),
      a.type('.'),
      a.type(','),
      a.backspace(3),
    ],
    [
      a.tab(1.5),
      ...['!', '@', '#', '\$', '%', '^', '&', '*', '(', ')', '-', '_']
          .map(a.type),
      a.type('\\', units: 1.5),
    ],
    [
      a.type('~', units: 1.25),
      ...['`', '/', ':', ';', '"', '\'', '[', ']', '{', '}', '+', '=']
          .map(a.type),
      a.enter(1.75),
    ],
    [
      numeralToggle(2.25),
      ...['?', '<', '>', '|', '₹', '€', '£', '°', '•', '…'].map(a.type),
      numeralToggle(2.75),
    ],
    a.bottomRow(
      a.switchTo('தமிழ்', KeyboardLayout.tamil),
      a.switchTo('ABC', KeyboardLayout.english),
    ),
  ];
}
