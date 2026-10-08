# Desktop Keyboard UI — Implementation Plan

> Goal: on desktop (Windows / macOS / Linux / wide web), render a **large, modern,
> physical-keyboard-style** Tamil keyboard, **without breaking** any existing
> public API, mobile behaviour, or tests.

---

## 1. Current state (what we have today)

| Area | File | Observation |
|---|---|---|
| Entry widget | `lib/src/ui/keyboard_layout.dart` | `ThamizhiKeyboard(controller, theme)`. Width is **hard-capped at 600 px** (`keyboardWidth = 600`), so on a 1350 px desktop it is a small strip in the middle. |
| Key height | `keyboard_layout.dart:72` | `IntrinsicHeight` + `Expanded` rows → height comes from the text size, so keys are only ~25 px tall on desktop (see `out/Screen1.PNG`). |
| Key widget | `lib/src/ui/components/key_widget.dart` | Hard-coded padding (3/5), radius 6, icon 24, font 20. No hover, no pressed animation, no mouse cursor. **Publicly exported.** |
| Layouts | `lib/src/ui/layouts/*.dart` | Mobile-style rows (8 Tamil keys per row). No Enter, Tab, arrows, number row. Tamil layout is missing `ஒ` (engine supports it). |
| Theme | `lib/src/ui/theme/keyboard_theme.dart` | 5 colors + brightness, `const` constructor, **publicly exported**. |
| State | `lib/src/state/keyboard_controller.dart` | Always appends at end of text (ignores cursor / selection). On desktop users click with the mouse to move the cursor, so this becomes very visible. |
| Tests | `test/ui_test.dart`, `test/state_test.dart`, `test/engine_test.dart` | Must keep passing unchanged. |

Public API that must **not** change (exported from `lib/thamizhi_keyboard.dart`):
`ThamizhiKeyboard`, `KeyWidget`, `KeyboardTheme`, `KeyboardThemeData`,
`KeyboardController`, `KeyboardState`, `KeyboardLayout`, `TamilEngine`.

---

## 2. Strategy — "parallel desktop renderer, shared brain"

The safest way to not break anything is to **not modify the mobile UI path at all**.
Instead:

```
ThamizhiKeyboard
 ├─ resolves mode: compact | desktop     (new, auto by default)
 ├─ compact  → existing code path, byte-for-byte same widget tree
 └─ desktop  → NEW DesktopKeyboardView (new files only)
                 └─ uses the SAME KeyboardController + TamilEngine + KeyboardTheme
```

- Engine (`TamilEngine`) — **untouched**.
- State (`KeyboardController`) — **only additive** methods.
- Mobile layouts + `KeyWidget` — **untouched**.
- Theme — **only additive optional** fields with fallbacks.
- Desktop UI lives in a new folder `lib/src/ui/desktop/` and is not exported
  initially (keeps public API surface small; we can export later).

Escape hatch for any app that dislikes the new look:
`ThamizhiKeyboard(controller: c, mode: KeyboardMode.compact)` → exactly today's UI.

---

## 3. New / changed files

```
lib/
  thamizhi_keyboard.dart                     (+1 export: keyboard_mode.dart)
  src/
    state/
      keyboard_controller.dart               (additive methods only — Phase 3)
    ui/
      keyboard_layout.dart                   (add optional params + branch)
      keyboard_mode.dart                     NEW  enum KeyboardMode + resolver
      theme/keyboard_theme.dart              (additive optional fields + copyWith)
      components/key_widget.dart             UNCHANGED
      layouts/*.dart                         UNCHANGED
      desktop/                               NEW
        desktop_keyboard_view.dart           shell: sizing, container, layout switch
        desktop_key.dart                     modern keycap (hover/press/cursor)
        desktop_key_spec.dart                data model for a key (label, width, action)
        desktop_metrics.dart                 sizing tokens computed from width
        layouts/
          desktop_tamil_layout.dart
          desktop_english_layout.dart
          desktop_symbol_layout.dart         (numbers + symbols + Tamil numerals)
    input/
      physical_keyboard_bridge.dart          NEW (Phase 4, opt-in)
test/
  desktop_ui_test.dart                       NEW
  keyboard_mode_test.dart                    NEW
  controller_cursor_test.dart                NEW (Phase 3)
```

---

## 4. Phase 1 — Mode switch + sizing (foundation, zero visual change on mobile)

### 4.1 `KeyboardMode` (new, `keyboard_mode.dart`)
```dart
enum KeyboardMode { auto, compact, desktop }
```
Resolver (pure function, easy to unit-test):
```dart
bool useDesktop(KeyboardMode mode, double width, TargetPlatform platform, bool isWeb) {
  switch (mode) {
    case KeyboardMode.compact: return false;
    case KeyboardMode.desktop: return true;
    case KeyboardMode.auto:
      final desktopPlatform = isWeb ||
          platform == TargetPlatform.windows ||
          platform == TargetPlatform.macOS ||
          platform == TargetPlatform.linux;
      return desktopPlatform && width >= 840; // Material "expanded" breakpoint
  }
}
```
Width check means a narrow side-panel on desktop still gets the compact keyboard.

### 4.2 `ThamizhiKeyboard` — new **optional** params only
```dart
const ThamizhiKeyboard({
  super.key,
  required this.controller,
  this.theme,
  this.mode = KeyboardMode.auto,     // NEW
  this.desktopMaxWidth = 1280,       // NEW
  this.fontFamily,                   // NEW (e.g. 'Noto Sans Tamil'), desktop only
});
```
Inside `build`, in the existing `LayoutBuilder`:
```dart
if (useDesktop(...)) return DesktopKeyboardView(controller: _keyboardController, ...);
// else: existing code below, unchanged (600 cap etc.)
```
Also add the missing `didUpdateWidget` so a new `TextEditingController` is picked up
(bug fix, no API change).

### 4.3 `DesktopMetrics` — size scales with available width
Physical keyboards are ~15 key-units wide. Compute one unit from the width:
```
unit      = clamp(availableWidth / 15.5, 52, 76)   // px per 1u key
keyHeight = unit * 0.92
gap       = unit * 0.10
radius    = unit * 0.18
font      = unit * 0.38   (Tamil glyphs need more room than Latin)
total h   ≈ 5 rows * (keyHeight + gap) + padding  ≈ 300–380 px
```
So at 1280 px wide → ~76 px keys (vs ~25 px today). Real keyboard proportions.

### 4.4 Theme — additive, optional
```dart
final Color? accentColor;     // Enter / active Shift / Caps indicator
final Color? hoverColor;      // derived from keyColor if null
final Color? keyBorderColor;  // subtle 1px keycap edge
final Color? keyEdgeColor;    // darker "bottom lip" for 3D keycap look
KeyboardTheme copyWith({...});
```
All nullable with computed fallbacks → `KeyboardTheme.light`, `.dark`, and every
existing user's `const KeyboardTheme(...)` still compile and look identical on mobile.

---

## 5. Phase 2 — Modern desktop UI

### 5.1 `DesktopKey` (new widget, `KeyWidget` untouched)
- Takes a `DesktopKeySpec` (label, optional sub-label, width in units, style: normal / modifier / accent, onTap, onLongPress).
- **Keycap look:** rounded rect, 1px border, darker bottom edge (3D lip), soft shadow.
- **Hover:** `MouseRegion` → lighter fill + `SystemMouseCursors.click`.
- **Press:** `AnimatedContainer`/`AnimatedScale` ~80 ms — key sinks 2 px, lip shrinks.
- **Physical-key highlight:** same "pressed" visual can be triggered externally (Phase 4).
- **Sub-label:** small top-left hint (e.g. shifted symbol, or English key that maps to it).
- **Accessibility:** `Semantics(button: true, label: ...)`, `Tooltip` for icon-only keys.
- Haptics skipped on desktop (no-op there anyway).
- Wrapped in `RepaintBoundary` like the current key.

### 5.2 `DesktopKeyboardView` (shell)
- Full width up to `desktopMaxWidth`, centred, rounded "deck" container (radius 16,
  padding, subtle gradient/shadow from theme).
- Rows rendered from `List<List<DesktopKeySpec>>` → each key gets
  `width = spec.units * unit + (spec.units - 1) * gap`. Rows align on the right edge
  exactly like a real keyboard.
- Optional slim top bar: current language pill (`தமிழ் | EN`) + hide-keyboard button.
- Listens to `KeyboardController` via `ValueListenableBuilder` (same as today).

### 5.3 Desktop layouts (physical-keyboard shaped, 5 rows)

**Tamil** (grouped phonetically; also adds `ஒ` and Grantha letters missing on mobile):
```
Row 1 │ ௧ ௨ ௩ ௪ ௫ ௬ ௭ ௮ ௯ ௦ - =                    │ ⌫ Backspace (2u)
Row 2 │ Tab(1.5u) │ அ ஆ இ ஈ உ ஊ எ ஏ ஐ ஒ ஓ ஔ           │ ஃ (1.5u)
Row 3 │ Caps→EN(1.75u) │ க் ங் ச் ஞ் ட் ண் த் ந் ப் ம் ற் ன்   │ Enter (2.25u, accent)
Row 4 │ Shift(2.25u) │ ய் ர் ல் வ் ழ் ள் ஜ் ஷ் ஸ் ஹ்          │ Shift (2.75u)
Row 5 │ EN │ 123 │        Space (6u)        │ ← → │ ⌨ hide
```
(Shift on Tamil can switch Row 1 between Tamil numerals and Arabic digits, or
show `க்ஷ`, `ஸ்ரீ` — decide in review.)

**English:** standard full QWERTY with number row, Tab, Caps, both Shifts, Enter,
symbols on Shift (`1→!`, `2→@` …). Caps lock indicator dot uses `accentColor`.

**Symbols (123):** numbers + symbol grid + toggle to Tamil numerals, reusing the
same characters as the mobile `NumberLayout` / `TamilNumberLayout`.

All keys call the **existing** controller methods (`onKeyPress`, `onBackspace`,
`switchLayout`, `toggleShift`), so Tamil composition (`க்` + `ஆ` → `கா`) works
identically on desktop.

---

## 6. Phase 3 — Desktop-grade editing (additive controller methods)

Needed because desktop users click with the mouse to place the cursor.

| New method | Behaviour |
|---|---|
| `onEnter()` | inserts `\n` |
| `onTab()` | inserts `\t` (or configurable) |
| `moveCursor(int delta)` | ← / → keys |
| internal `_insertAtCursor` | runs `TamilEngine.processInput(prefix, char)` on the text **before** the cursor, then re-appends the suffix and restores the selection |

Compatibility rule: when the selection is invalid (`-1`) or at the end of the text,
the result is **identical** to today's append behaviour → all existing
`state_test.dart` expectations keep passing. Backspace gets the same treatment
(delete before cursor / delete selection).

---

## 7. Phase 4 — Physical keyboard bridge (optional, opt-in)

`ThamizhiKeyboard(enablePhysicalKeyboard: true)` (default `false`):
- `HardwareKeyboard.instance.addHandler` → highlight the matching on-screen key
  (the "real keyboard" feel when typing).
- Optional mapping of physical keys to Tamil letters (e.g. Tamil99 or phonetic
  map), routed through `KeyboardController`, so typing on a laptop keyboard
  produces Tamil.
- Off by default, because if the host `TextField` is not `readOnly` it would
  double-insert characters. Documented clearly in README.

---

## 8. Testing plan (nothing existing is modified)

1. **Existing tests run unchanged:** `flutter test` must stay green after every phase.
   (Note: `ui_test.dart` runs on the default 800×600 test surface and default
   test platform = Android → resolver picks `compact` → same tree as today.)
2. `keyboard_mode_test.dart` — resolver unit tests: every mode × platform × width.
3. `desktop_ui_test.dart`
   - Set `tester.view.physicalSize` to 1024×768, 1440×900, 1920×1080 and
     `debugDefaultTargetPlatformOverride = TargetPlatform.windows`.
   - Assert no RenderFlex overflow for **every** layout (Tamil, English, Caps, 123,
     Tamil numerals).
   - Assert key height ≥ 52 px.
   - Tap `க்` then `ஆ` on desktop view → text `கா`.
   - `mode: KeyboardMode.compact` on desktop → old widget tree (finds `KeyWidget`,
     not `DesktopKey`).
   - Hover test via `TestGesture(kind: PointerDeviceKind.mouse)`.
4. `controller_cursor_test.dart` — insert/backspace in middle of text, Tamil
   composition at cursor, end-of-text parity with old behaviour.
5. Optional golden tests for light/dark desktop at 1440 px.
6. Manual: `cd example && flutter run -d windows` (and `-d chrome`, `-d macos`).

---

## 9. Release / docs

- Bump `pubspec.yaml` version `0.1.1 → 0.2.0` (minor = additive features).
- `CHANGELOG.md`: "Added desktop keyboard mode (auto), new optional theme tokens,
  cursor-aware editing, Enter/Tab/arrow keys."
- README: new "Desktop mode" section + `mode` / `desktopMaxWidth` / `fontFamily`
  params + new desktop screenshot in `out/`.
- Example app: let the input field container grow wider on desktop (currently
  `maxWidth: 600`) and pass `fontFamily: 'Noto Sans Tamil'`.
- Add `DESKTOP_UI_PLAN.md` to `.pubignore` so this plan isn't published to pub.dev.

---

## 10. Backward-compatibility checklist

- [ ] `ThamizhiKeyboard(controller:, theme:)` compiles and behaves the same on mobile.
- [ ] No existing constructor parameter removed, renamed, or made required.
- [ ] `KeyWidget` source unchanged.
- [ ] `KeyboardTheme.light` / `.dark` and custom `const KeyboardTheme(...)` still compile.
- [ ] `KeyboardController` existing methods: same results when cursor is at end.
- [ ] `TamilEngine` unchanged.
- [ ] All existing tests pass without edits.
- [ ] `mode: KeyboardMode.compact` reproduces today's desktop UI exactly.
- [ ] `flutter analyze` clean; `dart pub publish --dry-run` clean.

---

## 11. Open decisions (recommended default in **bold**)

1. Default mode: **`auto` (desktop look on wide desktop/web automatically)** vs
   `compact` (desktop look only when the app opts in). `auto` is a visual change for
   existing desktop users, but not an API break and has the `compact` escape hatch.
2. Should tablets (iPad landscape) get the desktop layout? **No for now** — touch
   devices keep compact; can add `KeyboardMode.desktop` manually.
3. Tamil desktop key arrangement: **phonetic grouping (section 5.3)** vs Tamil99
   positions (better if users also type on a physical keyboard).
4. Physical keyboard bridge (Phase 4): **ship later, opt-in**.

## 12. Suggested order of work

1. Phase 1 (mode + metrics + theme fields) → run tests.
2. Phase 2 (DesktopKey + shell + 3 layouts) → run tests + manual Windows run.
3. Phase 3 (cursor-aware controller) → run tests.
4. Docs, example, version bump.
5. Phase 4 later as a separate release.
