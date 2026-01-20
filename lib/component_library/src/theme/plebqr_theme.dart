import 'package:flutter/material.dart';
import 'package:plebqr_india/component_library/src/theme/plebqr_theme_data.dart';

class PlebQrTheme extends InheritedWidget {
  const PlebQrTheme({
    required super.child,
    required this.lightTheme,
    required this.darkTheme,
    super.key,
  });

  final PlebQrThemeData lightTheme;
  final PlebQrThemeData darkTheme;

  @override
  bool updateShouldNotify(PlebQrTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;

  static PlebQrThemeData of(BuildContext context) {
    final PlebQrTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<PlebQrTheme>();
    assert(inheritedTheme != null, 'No PlebQrTheme found in context');
    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedTheme!.darkTheme
        : inheritedTheme!.lightTheme;
  }
}
