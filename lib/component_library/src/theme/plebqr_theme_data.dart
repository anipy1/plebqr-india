import 'package:flutter/material.dart';
import 'package:plebqr_india/component_library/src/theme/spacing.dart';

const _dividerThemeData = DividerThemeData(space: 0);

// If the number of properties get too big, we can start grouping them in
// classes like Flutter does with TextTheme, ButtonTheme, etc, inside ThemeData.
abstract class PlebQrThemeData {
  ThemeData get materialThemeData;

  double screenMargin = Spacing.mediumLarge;

  double gridSpacing = Spacing.mediumLarge;

  TextStyle quoteTextStyle = const TextStyle(
    fontFamily: 'Fondamento',
    package: 'plebqr_india',
  );
}

class LightPlebQrThemeData extends PlebQrThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.black.toMaterialColor(),
    dividerTheme: _dividerThemeData,
  );
}

class DarkPlebQrThemeData extends PlebQrThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.white.toMaterialColor(),
    dividerTheme: _dividerThemeData,
  );
}

extension on Color {
  Map<int, Color> _toSwatch() => {
    50: withValues(alpha: .1),
    100: withValues(alpha: .2),
    200: withValues(alpha: .3),
    300: withValues(alpha: .4),
    400: withValues(alpha: .5),
    500: withValues(alpha: .6),
    600: withValues(alpha: .7),
    700: withValues(alpha: .8),
    800: withValues(alpha: .9),
    900: this,
  };

  MaterialColor toMaterialColor() => MaterialColor(value, _toSwatch());
}
