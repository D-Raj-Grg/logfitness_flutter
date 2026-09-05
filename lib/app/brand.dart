import 'package:flutter/material.dart';

/// Design tokens for the Lord of Gyms brand.
///
/// Every colour, radius, and spacing value used anywhere in the app comes
/// from here (or from the [ThemeData] built off it in `theme.dart`) — never
/// hardcode a colour at a call site.
abstract final class Brand {
  /// Seed colour for [ColorScheme.fromSeed]: a confident, high-energy
  /// amber-orange. Chosen over stock "Flutter blue" (generic, unbranded) and
  /// the fitness-app-cliché green (low legibility on the strong reds/ambers
  /// gym branding in the Nepali market tends to use) — orange reads as
  /// energetic and Nepali-flag-adjacent without copying it, and holds up in
  /// both a bright front-desk counter and a dim gym floor.
  static const Color seed = Color(0xFFE0621A);

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 20;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
}
