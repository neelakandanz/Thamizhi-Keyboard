import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_key_spec.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_metrics.dart';
import 'package:thamizhi_keyboard/src/ui/desktop/desktop_palette.dart';

/// A physical-keyboard style keycap with hover, press and key-repeat.
///
/// The action fires on pointer down, like a real keyboard. Keys with
/// [DesktopKeySpec.repeat] fire again while held.
class DesktopKey extends StatefulWidget {
  final DesktopKeySpec spec;
  final DesktopMetrics metrics;
  final DesktopPalette palette;
  final String? fontFamily;

  const DesktopKey({
    super.key,
    required this.spec,
    required this.metrics,
    required this.palette,
    this.fontFamily,
  });

  static const Duration repeatDelay = Duration(milliseconds: 400);
  static const Duration repeatInterval = Duration(milliseconds: 55);

  @override
  State<DesktopKey> createState() => _DesktopKeyState();
}

class _DesktopKeyState extends State<DesktopKey> {
  bool _hovered = false;
  bool _pressed = false;
  Timer? _repeatTimer;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons & kPrimaryButton == 0) {
      return;
    }
    setState(() => _pressed = true);
    widget.spec.onTap();
    if (widget.spec.repeat) {
      _repeatTimer = Timer(DesktopKey.repeatDelay, () {
        _repeatTimer = Timer.periodic(
            DesktopKey.repeatInterval, (_) => widget.spec.onTap());
      });
    }
  }

  void _onPointerEnd(PointerEvent event) {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    // The key may have been replaced by a layout switch it triggered.
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  void _setHovered(bool value) {
    if (mounted && _hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final m = widget.metrics;
    final p = widget.palette;

    final fill = _pressed
        ? p.pressed(spec.style)
        : _hovered
            ? p.hover(spec.style)
            : p.fill(spec.style);
    final depth = m.depth;
    final radius = BorderRadius.circular(m.radius);

    return SizedBox(
      width: spec.units * m.unit,
      height: m.rowHeight,
      child: Padding(
        padding: EdgeInsets.all(m.gap / 2),
        child: Semantics(
          button: true,
          label: spec.semanticLabel ?? spec.label,
          onTap: spec.onTap,
          excludeSemantics: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerEnd,
              onPointerCancel: _onPointerEnd,
              // Claims the tap in the gesture arena (like InkWell on the
              // compact keys) so an ancestor's onTap, e.g. a "tap outside to
              // hide the keyboard" handler, doesn't fire for key presses.
              child: GestureDetector(
                onTap: () {},
                excludeFromSemantics: true,
                child: RepaintBoundary(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 70),
                    curve: Curves.easeOut,
                    transform:
                        Matrix4.translationValues(0, _pressed ? depth : 0, 0),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: radius,
                      border: Border.all(color: p.border),
                      boxShadow: [
                        // Keycap lip: shrinks as the key sinks.
                        BoxShadow(
                          color: p.edge(spec.style),
                          offset: Offset(0, _pressed ? 0 : depth),
                        ),
                        BoxShadow(
                          color: p.shadow,
                          blurRadius: _pressed ? 1 : 4,
                          offset: Offset(0, _pressed ? 1 : depth + 1),
                        ),
                      ],
                    ),
                    child: _buildContent(p.foreground(spec.style)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foreground) {
    final spec = widget.spec;
    final m = widget.metrics;
    final p = widget.palette;
    final color = spec.active ? p.accent : foreground;

    Widget content;
    switch (spec.style) {
      case DesktopKeyStyle.character:
        content = Text(
          spec.label ?? '',
          style: TextStyle(
            color: color,
            fontSize: m.fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: widget.fontFamily,
          ),
        );
        break;
      case DesktopKeyStyle.space:
        content = Text(
          spec.label ?? '',
          style: TextStyle(
            color: p.subText,
            fontSize: m.modifierFontSize,
            fontFamily: widget.fontFamily,
          ),
        );
        break;
      case DesktopKeyStyle.modifier:
      case DesktopKeyStyle.accent:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spec.icon != null)
              Icon(spec.icon, color: color, size: m.iconSize),
            if (spec.icon != null && spec.label != null)
              SizedBox(width: m.unit * 0.08),
            if (spec.label != null)
              Text(
                spec.label!,
                style: TextStyle(
                  color: color,
                  fontSize: m.modifierFontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: widget.fontFamily,
                ),
              ),
          ],
        );
        break;
    }

    final inset = m.unit * 0.1;
    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: inset),
              child: FittedBox(fit: BoxFit.scaleDown, child: content),
            ),
          ),
        ),
        if (spec.subLabel != null)
          Positioned(
            top: inset * 0.5,
            left: inset,
            child: Text(
              spec.subLabel!,
              style: TextStyle(
                color: p.subText,
                fontSize: m.subFontSize,
                fontFamily: widget.fontFamily,
              ),
            ),
          ),
        if (spec.active)
          Positioned(
            top: inset,
            left: inset,
            child: Container(
              width: m.unit * 0.08,
              height: m.unit * 0.08,
              decoration:
                  BoxDecoration(color: p.accent, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
