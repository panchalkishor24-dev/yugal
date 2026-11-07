import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding.dart';

void main() => runApp(const YugalApp());

class YugalApp extends StatelessWidget {
  const YugalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Yugal',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const OnboardingScreen(),
      ),
    );
  }
}
