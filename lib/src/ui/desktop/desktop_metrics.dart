import 'dart:math' as math;

/// Sizing tokens for the desktop keyboard, derived from the available width.
///
/// Physical keyboards are about 15 key-units wide, so one unit (the width of a
/// regular letter key) is the available width divided by [rowUnits].
class DesktopMetrics {
  /// Width of every desktop row, in key units.
  static const double rowUnits = 15;

  /// Largest key unit in logical pixels, so keys stop growing on huge screens.
  static const double maxUnit = 76;

  /// Width of a 1u key slot in logical pixels (whole pixels, so rows built
  /// from quarter-unit keys always add up exactly).
  final double unit;

  const DesktopMetrics._(this.unit);

  factory DesktopMetrics.fromWidth(double availableWidth) {
    final unit = math.min(maxUnit, (availableWidth / rowUnits).floorToDouble());
    return DesktopMetrics._(math.max(unit, 1));
  }

  double get rowHeight => (unit * 0.9).roundToDouble();
  double get gap => (unit * 0.09).clamp(2.0, 8.0);
  double get radius => unit * 0.16;
  double get depth => (unit * 0.05).clamp(1.5, 4.0);
  double get fontSize => unit * 0.36;
  double get subFontSize => unit * 0.2;
  double get modifierFontSize => unit * 0.2;
  double get iconSize => unit * 0.32;
}
