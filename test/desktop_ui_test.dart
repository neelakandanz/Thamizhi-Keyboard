import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thamizhi_keyboard/thamizhi_keyboard.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_keyboard_view.dart';

void main() {
  void setScreen(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget keyboard, {ThemeData? theme}) => MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            children: [const Spacer(), keyboard],
          ),
        ),
      );

  Future<KeyboardController> pumpDesktopView(
    WidgetTester tester,
    TextEditingController text, {
    double width = 1440,
  }) async {
    setScreen(tester, Size(width, 900));
    final controller = KeyboardController(textController: text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(app(DesktopKeyboardView(controller: controller)));
    return controller;
  }

  group('Mode selection', () {
    testWidgets('auto renders the desktop keyboard on wide desktop',
        (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(
          app(ThamizhiKeyboard(controller: TextEditingController())));
      expect(find.byType(DesktopKey), findsWidgets);
      expect(find.byType(KeyWidget), findsNothing);
    }, variant: TargetPlatformVariant.desktop());

    testWidgets('auto keeps the compact keyboard on mobile platforms',
        (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(
          app(ThamizhiKeyboard(controller: TextEditingController())));
      expect(find.byType(KeyWidget), findsWidgets);
      expect(find.byType(DesktopKey), findsNothing);
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('auto keeps the compact keyboard in a narrow desktop window',
        (tester) async {
      setScreen(tester, const Size(700, 900));
      await tester.pumpWidget(
          app(ThamizhiKeyboard(controller: TextEditingController())));
      expect(find.byType(KeyWidget), findsWidgets);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

    testWidgets('compact mode restores the original keyboard on desktop',
        (tester) async {
      setScreen(tester, const Size(1440, 900));
      await tester.pumpWidget(app(ThamizhiKeyboard(
        controller: TextEditingController(),
        mode: KeyboardMode.compact,
      )));
      expect(find.byType(KeyWidget), findsWidgets);
      expect(find.byType(DesktopKey), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

    testWidgets('desktop mode can be forced on any platform', (tester) async {
      setScreen(tester, const Size(1024, 768));
      await tester.pumpWidget(app(ThamizhiKeyboard(
        controller: TextEditingController(),
        mode: KeyboardMode.desktop,
      )));
      expect(find.byType(DesktopKey), findsWidgets);
    });
  });

  group('Desktop layouts', () {
    for (final width in [840.0, 1024.0, 1440.0, 1920.0]) {
      testWidgets('every layout fits at ${width.toInt()} px', (tester) async {
        final controller =
            await pumpDesktopView(tester, TextEditingController(), width: width);
        for (final layout in KeyboardLayout.values) {
          controller.switchLayout(layout);
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$layout');
        }
      });
    }

    testWidgets('keys are large on a desktop screen', (tester) async {
      await pumpDesktopView(tester, TextEditingController());
      final size = tester.getSize(find.byType(DesktopKey).first);
      expect(size.height, greaterThanOrEqualTo(52));
      expect(size.width, greaterThanOrEqualTo(52));
    });

    testWidgets('keyboard width is capped by maxWidth', (tester) async {
      await pumpDesktopView(tester, TextEditingController(), width: 2560);
      final rowWidth = tester.getSize(find.byType(Row).first).width;
      expect(rowWidth, lessThanOrEqualTo(1280));
    });

    testWidgets('Tamil layout includes ஒ and Grantha letters', (tester) async {
      await pumpDesktopView(tester, TextEditingController());
      for (final letter in ['ஒ', 'ஜ்', 'ஷ்', 'ஸ்', 'ஹ்', 'ஸ்ரீ']) {
        expect(find.text(letter), findsOneWidget, reason: letter);
      }
    });
  });

  group('Desktop typing', () {
    testWidgets('Tamil composition works through desktop keys',
        (tester) async {
      final text = TextEditingController();
      await pumpDesktopView(tester, text);
      await tester.tap(find.text('க்'));
      await tester.tap(find.text('ஆ'));
      await tester.tap(find.text('ம்'));
      expect(text.text, 'காம்');
    });

    testWidgets('Shift is one-shot in English', (tester) async {
      final text = TextEditingController();
      final controller = await pumpDesktopView(tester, text);
      controller.switchLayout(KeyboardLayout.english);
      await tester.pump();

      await tester.tap(find.text('Shift').first);
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('a'));
      await tester.tap(find.text('1'));
      expect(text.text, 'Aa1');
    });

    testWidgets('Shift types the alternate symbol', (tester) async {
      final text = TextEditingController();
      final controller = await pumpDesktopView(tester, text);
      controller.switchLayout(KeyboardLayout.english);
      await tester.pump();

      await tester.tap(find.text('Shift').last);
      await tester.pump();
      await tester.tap(find.text('!'));
      expect(text.text, '!');
    });

    testWidgets('Caps lock stays on and shows the active indicator',
        (tester) async {
      final text = TextEditingController();
      final controller = await pumpDesktopView(tester, text);
      controller.switchLayout(KeyboardLayout.english);
      await tester.pump();

      await tester.tap(find.text('Caps'));
      await tester.pump();
      expect(controller.value.currentLayout, KeyboardLayout.englishCaps);
      await tester.tap(find.text('Q'));
      await tester.tap(find.text('W'));
      expect(text.text, 'QW');
    });

    testWidgets('Tamil Shift switches the number row to Tamil numerals',
        (tester) async {
      final text = TextEditingController();
      await pumpDesktopView(tester, text);
      await tester.tap(find.text('Shift').first);
      await tester.pump();
      await tester.tap(find.text('௫'));
      await tester.pump();
      await tester.tap(find.text('5'));
      expect(text.text, '௫5');
    });

    testWidgets('Enter, space and arrows edit at the cursor', (tester) async {
      final text = TextEditingController();
      final controller = await pumpDesktopView(tester, text);
      controller.switchLayout(KeyboardLayout.english);
      await tester.pump();

      await tester.tap(find.text('a'));
      await tester.tap(find.text('c'));
      await tester.tap(find.bySemanticsLabel('Cursor left'));
      await tester.tap(find.text('b'));
      await tester.tap(find.bySemanticsLabel('Cursor right'));
      await tester.tap(find.text('Enter'));
      await tester.tap(find.text('English'));
      expect(text.text, 'abc\n ');
    });

    testWidgets('Backspace repeats while held', (tester) async {
      final text = TextEditingController(text: 'abcdefghij');
      await pumpDesktopView(tester, text);

      final gesture = await tester
          .startGesture(tester.getCenter(find.bySemanticsLabel('Backspace')));
      expect(text.text, 'abcdefghi');
      await tester.pump(DesktopKey.repeatDelay);
      await tester.pump(DesktopKey.repeatInterval * 3);
      await gesture.up();
      expect(text.text.length, lessThanOrEqualTo(6));

      final afterRelease = text.text;
      await tester.pump(const Duration(seconds: 1));
      expect(text.text, afterRelease);
    });

    testWidgets('Layout switch keys change the layout', (tester) async {
      final text = TextEditingController();
      final controller = await pumpDesktopView(tester, text);
      await tester.tap(find.text('123'));
      await tester.pump();
      expect(controller.value.currentLayout, KeyboardLayout.numbers);
      await tester.tap(find.text('௧௨௩').first);
      await tester.pump();
      expect(controller.value.currentLayout, KeyboardLayout.tamilNumbers);
      await tester.tap(find.text('ABC'));
      await tester.pump();
      expect(controller.value.currentLayout, KeyboardLayout.english);
      await tester.tap(find.text('தமிழ்'));
      await tester.pump();
      expect(controller.value.currentLayout, KeyboardLayout.tamil);
    });
  });

  group('Desktop interaction', () {
    Color keyFill(WidgetTester tester, Finder key) {
      final container = tester.widget<AnimatedContainer>(
          find.descendant(of: key, matching: find.byType(AnimatedContainer)));
      return (container.decoration! as BoxDecoration).color!;
    }

    testWidgets('hovering a key changes its fill', (tester) async {
      await pumpDesktopView(tester, TextEditingController());
      final key = find.ancestor(
          of: find.text('க்'), matching: find.byType(DesktopKey));
      final idle = keyFill(tester, key);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(key));
      await tester.pump();
      expect(keyFill(tester, key), isNot(idle));
    });

    testWidgets('key presses do not trigger an ancestor onTap',
        (tester) async {
      setScreen(tester, const Size(1440, 900));
      final text = TextEditingController();
      final controller = KeyboardController(textController: text);
      addTearDown(controller.dispose);
      var outerTaps = 0;
      await tester.pumpWidget(app(GestureDetector(
        onTap: () => outerTaps++,
        child: DesktopKeyboardView(controller: controller),
      )));
      await tester.tap(find.text('க்'));
      await tester.tap(find.text('அ'));
      expect(text.text, 'க');
      expect(outerTaps, 0);
    });

    testWidgets('right-click does not type', (tester) async {
      final text = TextEditingController();
      await pumpDesktopView(tester, text);
      final mouse = await tester.startGesture(
        tester.getCenter(find.text('க்')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await mouse.up();
      expect(text.text, isEmpty);
    });

    testWidgets('uses the custom theme accent for Enter', (tester) async {
      setScreen(tester, const Size(1440, 900));
      const accent = Color(0xFF00AA55);
      final controller =
          KeyboardController(textController: TextEditingController());
      addTearDown(controller.dispose);
      await tester.pumpWidget(app(KeyboardThemeData(
        theme: KeyboardTheme.dark.copyWith(accentColor: accent),
        child: DesktopKeyboardView(controller: controller),
      )));
      final enter = find.ancestor(
          of: find.text('Enter'), matching: find.byType(DesktopKey));
      expect(keyFill(tester, enter), accent);
    });
  });
}
