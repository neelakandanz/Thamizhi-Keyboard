import 'package:thamizhi_keyboard/src/state/keyboard_state.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_actions.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';

const _digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
const _tamilDigits = ['௧', '௨', '௩', '௪', '௫', '௬', '௭', '௮', '௯', '௦'];

/// உயிர் எழுத்துகள்
const _vowels = ['அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ'];

/// வல்லினம் + மெல்லினம், paired as on the Tamil alphabet chart.
const _hardSoft = [
  'க்', 'ங்', 'ச்', 'ஞ்', 'ட்', 'ண்', //
  'த்', 'ந்', 'ப்', 'ம்', 'ற்', 'ன்',
];

/// இடையினம் + கிரந்தம்
const _mediumGrantha = [
  'ய்', 'ர்', 'ல்', 'வ்', 'ழ்', 'ள்', //
  'ஜ்', 'ஷ்', 'ஸ்', 'ஹ்',
];

/// Full-size Tamil layout grouped phonetically. Shift swaps the number row
/// to Tamil numerals.
List<List<DesktopKeySpec>> buildDesktopTamilRows(DesktopKeyActions a) {
  return [
    [
      for (var i = 0; i < _digits.length; i++)
        a.type(_digits[i], shifted: _tamilDigits[i]),
      a.type('-', shifted: '_'),
      a.type('=', shifted: '+'),
      a.backspace(3),
    ],
    [
      a.tab(1.5),
      ..._vowels.map(a.type),
      a.type('ஃ', units: 1.5),
    ],
    [
      a.type('ஸ்ரீ', units: 1.25),
      ..._hardSoft.map(a.type),
      a.enter(1.75),
    ],
    [
      a.shift(2.25),
      ..._mediumGrantha.map(a.type),
      a.shift(2.75),
    ],
    a.bottomRow(
      a.switchTo('EN', KeyboardLayout.english),
      a.switchTo('123', KeyboardLayout.numbers),
      spaceLabel: 'தமிழ்',
    ),
  ];
}
