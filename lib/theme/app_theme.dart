import 'package:flutter/material.dart';

abstract final class PetVerseColors {
  static const forest = Color(0xFF346B5C);
  static const coral = Color(0xFFE27957);
  static const honey = Color(0xFFE0AE4B);
  static const background = Color(0xFFFFF8EF);
  static const ink = Color(0xFF26352F);
}

class PetVerseTheme {
  const PetVerseTheme._();

  static ThemeData get light {
    final colors =
        ColorScheme.fromSeed(
          seedColor: PetVerseColors.forest,
          surface: PetVerseColors.background,
        ).copyWith(
          secondary: PetVerseColors.coral,
          tertiary: PetVerseColors.honey,
          surface: PetVerseColors.background,
          primaryContainer: const Color(0xFFDDECE5),
          secondaryContainer: const Color(0xFFFCE5DC),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: PetVerseColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: PetVerseColors.background,
        foregroundColor: PetVerseColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8DFD8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
    );
  }
}
