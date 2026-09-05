import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

/// Shared Material 3 theming for Lord of Gyms.
///
/// [appLightTheme] and [appDarkTheme] are two faces of one system: same
/// seed colour, same typography, same component shapes — only brightness
/// differs. Do not hardcode colours in feature code; extend the themes here
/// instead.
ThemeData _baseTheme(ColorScheme colorScheme) {
  final textTheme = ThemeData(brightness: colorScheme.brightness).textTheme.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600),
        labelLarge: const TextStyle(fontWeight: FontWeight.w600),
      );

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Brand.radiusMedium),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      margin: const EdgeInsets.all(Brand.spaceSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceLg,
          vertical: Brand.spaceMd,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceLg,
          vertical: Brand.spaceMd,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: shape),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceMd,
        vertical: Brand.spaceMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
  );
}

/// Light theme for Lord of Gyms.
ThemeData get appLightTheme => _baseTheme(
      ColorScheme.fromSeed(
        seedColor: Brand.seed,
        brightness: Brightness.light,
      ),
    );

/// Dark theme for Lord of Gyms.
ThemeData get appDarkTheme => _baseTheme(
      ColorScheme.fromSeed(
        seedColor: Brand.seed,
        brightness: Brightness.dark,
      ),
    );
