## 0.2.0

### Full-size desktop keyboard
* 🖥️ **Desktop mode**: New `KeyboardMode` (`auto` / `compact` / `desktop`). On Windows, macOS, Linux and wide web windows the keyboard now renders as a large, physical-keyboard style layout that scales with the window (up to `desktopMaxWidth`, default 1280 px).
* ⌨️ **Desktop keys**: Hover and press animations, mouse cursor, one-shot Shift, Caps Lock, Tab, Enter, ← / → arrows, and key-repeat for Backspace and arrows.
* 🔤 **Tamil desktop layout**: Phonetically grouped rows, adds `ஒ`, Grantha letters (`ஜ் ஷ் ஸ் ஹ் ஸ்ரீ`) and Tamil numerals on Shift.
* ✍️ **Cursor-aware editing**: `KeyboardController` now types and deletes at the cursor / selection. New `onEnter()`, `onTab()` and `moveCursor()` methods. Behaviour is unchanged when there is no cursor (text is appended as before).
* 🎨 **Theme**: Optional `accentColor`, `hoverColor`, `keyBorderColor`, `keyEdgeColor` and a `copyWith` on `KeyboardTheme`.
* 🐞 `ThamizhiKeyboard` now picks up a replaced `TextEditingController`.
* ✅ Fully backward compatible: existing constructors, `KeyWidget` and the mobile layouts are unchanged; use `mode: KeyboardMode.compact` to keep the previous look on desktop.

## 0.1.1

### Layout Enhancements & Documentation
* 💅 **UI Refinement**: Extracted the Language change, Space bar, and Number change keys into a dedicated bottom navigation row to prevent key squeezing on mobile devices.
* 🖼️ **Documentation**: Updated README screenshots to showcase the latest layout and dark-themed Example Application.

## 0.1.0

### Major UI Redesign & Architecture Overhaul
* 🎉 **Native-like Premium UI**: Completely redesigned the keyboard interface to mimic native operating system keyboards (Gboard/iOS), featuring polished margins, touch feedback, and smooth `AnimatedContainer` resizing.
* 🚀 **Responsive & Adaptive**: Fully supports Mobile, Tablet, Desktop, and Web. Wraps intelligently using a robust `LayoutBuilder` wrapper (`ThamizhiKeyboard`).
* 🧠 **Pure Dart Engine**: Core Tamil composition logic has been decoupled into `TamilEngine` for ultra-fast, predictable input without hanging the UI thread (framework-agnostic text prediction capable).
* ⚡ **Optimized State Layer**: Replaced deeply coupled UI variables with `KeyboardController` (pure Flutter `ValueNotifier`) for blazing-fast redraws and zero memory leaks.
* 🎨 **Theming Support**: Introduced customizable `KeyboardTheme` providing drop-in `light` and `dark` modes mirroring native aesthetics.
* 🐞 **Performance Upgrades**: Enforced `flutter_lints ^3.0.0` with strict analyzer coverage, removed all lag-inducing nesting, and isolated touch ripples in a `RepaintBoundary`.
* 🔨 **Upgraded Dependencies**: Bumped to `sdk: ">=3.0.0 <4.0.0"` and Flutter `3.10.0`.

## 0.0.3

### initial release
* Simple Tamil Keybaord Package.


## 0.0.2

### Second release
* New thamizh number keys included.
* English keys included.
* New keyboard has special characters.
* Added mathematical characters.
* "New key: Return"
* Personalized color and font size options available.

## 0.0.3

### Third release
* English capital keys included.

