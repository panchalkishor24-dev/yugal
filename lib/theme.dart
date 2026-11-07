import 'package:flutter/material.dart';

/// Returns [c] with the given opacity (0..1) without using deprecated APIs.
Color fade(Color c, double o) => c.withAlpha((o * 255).round());

class C {
  static const saffron = Color(0xFFFF6B2B);
  static const rose = Color(0xFFE8356D);
  static const gold = Color(0xFFF5A623);
  static const green = Color(0xFF22C55E);
  static const darkBg = Color(0xFF0F0A06);
  static const darkCard = Color(0xFF1A1108);
  static const darkBorder = Color(0xFF2C1F0E);
  static const lightBg = Color(0xFFFFF8F0);
  static const lightBorder = Color(0xFFF0E2D3);
  static const muted = Color(0xFF8A7565);
  static const grad = LinearGradient(
    colors: [saffron, rose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradGold = LinearGradient(colors: [gold, saffron]);
}

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

extension Ctx on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get surf => isDark ? C.darkCard : Colors.white;
  Color get line => isDark ? C.darkBorder : C.lightBorder;
  Color get ink => isDark ? Colors.white : const Color(0xFF2A1A0E);
  Color get sub => isDark ? const Color(0xFFB8A090) : C.muted;
  Color get bg => isDark ? C.darkBg : C.lightBg;
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final border = dark ? C.darkBorder : C.lightBorder;
  OutlineInputBorder ob(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c),
      );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: dark ? C.darkBg : C.lightBg,
    colorScheme: ColorScheme.fromSeed(seedColor: C.saffron, brightness: b)
        .copyWith(
      primary: C.saffron,
      secondary: C.rose,
      surface: dark ? C.darkCard : Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? C.darkBg : C.lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: dark ? Colors.white : const Color(0xFF2A1A0E),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? C.darkCard : Colors.white,
      indicatorColor: fade(C.saffron, .18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? C.darkCard : Colors.white,
      border: ob(border),
      enabledBorder: ob(border),
      focusedBorder: ob(C.saffron),
    ),
  );
}
