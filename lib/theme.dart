import 'package:material_ui/material_ui.dart';

/// A lab-notebook look: warm paper, dark ink and one blue for links.
const paper = Color(0xFFF6F3EC);
const card = Color(0xFFFFFDF8);
const ink = Color(0xFF1F2328);
const muted = Color(0xFF5E636B);
const rule = Color(0xFFE2DDD2);
const accent = Color(0xFF2357C6);

ThemeData buildTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      surface: paper,
      onSurface: ink,
    ),
    scaffoldBackgroundColor: paper,
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(color: rule, space: 1),
  );
}
