# Thamizhi Keyboard SDK

[![Pub Version](https://img.shields.io/pub/v/thamizhi_keyboard?color=blue&style=flat-square)](https://pub.dev/packages/thamizhi_keyboard)
[![Flutter SDK](https://img.shields.io/badge/Flutter-%E2%89%A53.10.0-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-%E2%89%A53.0.0-blue.svg?style=flat-square&logo=dart)](https://dart.dev)
[![Platform support](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20macos%20%7C%20web%20%7C%20linux%20%7C%20windows-lightgrey.svg?style=flat-square)](#)

A highly professional, production-grade, and responsive Tamil keyboard SDK for Flutter. Designed to mimic the aesthetics and performance of native mobile keyboards (like Gboard and iOS) while smoothly adapting across mobile, tablet, desktop, and web environments.

---

## 📸 Showcase

| Mobile (Tamil) | Mobile (English) | Mobile (Numeric) |
| :---: | :---: | :---: |
| <img src="https://github.com/neelakandanz/thamizhi_keyboard/blob/main/out/Screen2.jpeg?raw=true" width="250" /> | <img src="https://github.com/neelakandanz/thamizhi_keyboard/blob/main/out/Screen3.jpeg?raw=true" width="250" /> | <img src="https://github.com/neelakandanz/thamizhi_keyboard/blob/main/out/Screen4.jpeg?raw=true" width="250" /> |

| Desktop / Web — full-size keyboard (dark) |
| :---: |
| <img src="https://github.com/neelakandanz/thamizhi_keyboard/blob/main/out/Screen5.png?raw=true" width="720" /> |

| Desktop / Web — light theme, Shift engaged |
| :---: |
| <img src="https://github.com/neelakandanz/thamizhi_keyboard/blob/main/out/Screen6.png?raw=true" width="720" /> |

---

## ✨ Features

- **Native-Like UI:** Crafted with proper spacing, realistic touch highlights, drop shadows, and polished boundaries to replicate top-tier system keyboards.
- **Ultra-Fast Performance:** Built using highly optimized `RepaintBoundary` wrappers and a minimal `ValueNotifier` state layer. Touch ripples do not rebuild your entire screen.
- **Full-Size Desktop Keyboard:** On Windows, macOS, Linux and wide web windows the keyboard automatically switches to a large, physical-keyboard style layout with hover and press animations, Tab / Enter / Shift / Caps / arrow keys, and key-repeat on Backspace.
- **Fluid Responsiveness:** Adaptive layouts that gracefully expand or constrain themselves automatically if running on an iPhone, iPad, or Desktop Web Browser using core `BoxConstraints`.
- **Pure Dart Tamil Engine:** Complex localized Tamil consonant/vowel compositions (e.g., `க் + ஆ = கா`) are completely decoupled into the abstract `TamilEngine` API, laying foundations for extensibility hooks (prediction/auto-correct engines).
- **Comprehensive Theming:** Features `light` and `dark` mode defaults via `KeyboardTheme`, switching interactively alongside your app's global state.
- **Usability Focus:** Integrated with native `HapticFeedback`, swift language switching (Tamil / English / Numbers), and robust swipe/backspace capabilities.

---

## ⌨️ How It Works (Typing Rules)

The keyboard intelligently combines pure consonants (Mei Ezhuthukkal) with vowels (Uyir Ezhuthukkal) automatically using the internal `TamilEngine`. 

When you type a consonant ending with the pulli (`்`) and immediately follow it with a vowel, the SDK replaces them with the correct compound character (Uyirmei Ezhuthukkal). 

**Examples of Combinations:**
- `க்` + `அ` = `க`
- `ச்` + `ஆ` = `சா`
- `ட்` + `இ` = `டி`
- `த்` + `ஈ` = `தீ`
- `ப்` + `உ` = `பு`
- `ம்` + `ஊ` = `மூ`
- `ய்` + `எ` = `யெ`
- `ர்` + `ஏ` = `ரே`
- `ல்` + `ஐ` = `லை`
- `வ்` + `ஒ` = `வொ`
- `ழ்` + `ஓ` = `ழோ`
- `ள்` + `ஔ` = `ளௌ`

This allows users to type naturally and quickly without needing a massive layout containing all 247 Tamil characters.

---

## 🏗 Modular Architecture

The SDK strictly follows separating presentation and logic:
1. **Engine Layer (`TamilEngine`)**: Handles instantaneous contextual replacements mathematically.
2. **State Layer (`KeyboardController`)**: Non-blocking `ValueNotifier` preserving active layouts, shift modifiers, and input routing. 
3. **UI Layer (`ThamizhiKeyboard`)**: The responsive, purely visual layer injected into the view hierarchy.

---

## 🚀 Installation & Usage

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  thamizhi_keyboard: ^0.1.1
```

### Best Practices Example

To deploy the keyboard effectively, manage it alongside a `TextEditingController` and link its visibility to the field's `FocusNode`. Using an `AnimatedContainer` delivers a gorgeous, premium slide-in aesthetic:

```dart
import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/thamizhi_keyboard.dart';

class MyKeyboardScreen extends StatefulWidget {
  @override
  _MyKeyboardScreenState createState() => _MyKeyboardScreenState();
}

class _MyKeyboardScreenState extends State<MyKeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _isKeyboardVisible = true);
      }
    });
  }

  void _hideKeyboard() {
    _focusNode.unfocus();
    setState(() => _isKeyboardVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Typing')),
      body: GestureDetector(
        onTap: _hideKeyboard, // Dismiss on outside click
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  readOnly: true, // Prevents default system keyboard
                  showCursor: true,
                  decoration: const InputDecoration(
                    hintText: "Type in Tamil...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            
            // Render the responsive ThamizhiKeyboard
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: _isKeyboardVisible ? null : 0,
              child: _isKeyboardVisible 
                  ? ThamizhiKeyboard(controller: _textController)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
```

Check out the `/example` directory for a fully styled, dark-themed production-ready demo utilizing Google Fonts and custom styling constraints.

---

## 🛠 Customization

You can seamlessly override the keyboard's color palette by passing a `KeyboardTheme` property directly:

```dart
ThamizhiKeyboard(
  controller: _textController,
  theme: const KeyboardTheme(
    backgroundColor: Colors.black,
    keyColor: Color(0xFF333333),
    altKeyColor: Color(0xFF1E1E1E),
    textColor: Colors.white,
    shadowColor: Colors.black45,
    brightness: Brightness.dark,
  ),
)
```

### Desktop mode

`ThamizhiKeyboard` picks its style with the `mode` parameter:

| Mode | Behaviour |
| --- | --- |
| `KeyboardMode.auto` (default) | Full-size desktop keyboard on Windows / macOS / Linux / web when at least 840 px wide; compact keyboard everywhere else. |
| `KeyboardMode.compact` | Always the original mobile-style keyboard. |
| `KeyboardMode.desktop` | Always the full-size desktop keyboard. |

```dart
ThamizhiKeyboard(
  controller: _textController,
  mode: KeyboardMode.auto,          // default
  desktopMaxWidth: 1280,            // keyboard stops growing past this width
  fontFamily: 'Noto Sans Tamil',    // optional font for desktop key labels
)
```

The desktop Tamil layout groups letters phonetically — vowels, then வல்லினம் / மெல்லினம், then இடையினம் and the Grantha letters (ஜ், ஷ், ஸ், ஹ், ஸ்ரீ). Shift switches the number row to Tamil numerals (௧–௦).

Typing, Backspace and the arrow keys work at the cursor position, so clicking inside the text field with a mouse and typing inserts text there.

The desktop look can be tuned with optional `KeyboardTheme` fields — all of them fall back to sensible defaults:

```dart
ThamizhiKeyboard(
  controller: _textController,
  theme: KeyboardTheme.dark.copyWith(
    accentColor: const Color(0xFF6B4EE6), // Enter + active Shift/Caps (defaults to ColorScheme.primary)
    hoverColor: const Color(0xFF555555),  // mouse hover fill
    keyBorderColor: Colors.white10,       // keycap outline
    keyEdgeColor: Colors.black54,         // 3D keycap lip
  ),
)
```

## 🤝 Contributing

We welcome contributors! Feel free to raise issues or submit pull requests with bug fixes or new features!
