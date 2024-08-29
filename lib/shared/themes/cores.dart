import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cores {
  static void init(BuildContext context) {}

  static const Color primaria = Color(0xFF001F3F);
  static const Color secundaria = Color(0xFF00B894);
  static const Color terciaria = Color.fromARGB(255, 81, 69, 0);
  static const Color escuro = Color(0xFF333333);
  static const Color foco = Color(0xFF8E44AD);
  static const Color atencao = Color(0xFFFF5722);
  static const Color branco = Color.fromARGB(255, 235, 235, 235);
  static const Color ruim = Color(0xFFFF4136);
  static const Color bom = Color(0xFF2ECC40);
  static const Color fundo = Color.fromARGB(255, 235, 235, 235);

  static ThemeData themaLight = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFF001F3F),
      primaryContainer: Color.fromARGB(255, 235, 235, 235),
      secondary: Color(0xFF00B894),
      secondaryContainer: Color.fromARGB(255, 235, 235, 235),
      tertiary: Color.fromARGB(255, 81, 69, 0),
      tertiaryContainer: Color.fromARGB(255, 235, 235, 235),
      appBarColor: Color(0xFF001F3F),
      error: Color(0xFFFF5722),
      errorContainer: Color(0xFFFF4136),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: false,
      tintedDisabledControls: false,
      blendOnColors: false,
      useTextTheme: true,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      inputDecoratorUnfocusedBorderIsColored: false,
      //alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      useInputDecoratorThemeInDialogs: true,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedLabel: false,
      navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedIcon: false,
      navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationBarIndicatorOpacity: 1.00,
      navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedLabel: false,
      navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedIcon: false,
      navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationRailIndicatorOpacity: 1.00,
      navigationRailBackgroundSchemeColor: SchemeColor.surface,
      navigationRailLabelType: NavigationRailLabelType.none,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.merriweather().fontFamily,
  );

  static ThemeData themaDark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xffc4d7f8),
      primaryContainer: Color(0xff577cbf),
      secondary: Color(0xfff1bbbb),
      secondaryContainer: Color(0xffcb6060),
      tertiary: Color(0xffdde5f5),
      tertiaryContainer: Color(0xff7297d9),
      appBarColor: Color(0xffdde5f5),
      error: null,
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: false,
      tintedDisabledControls: false,
      useTextTheme: true,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      inputDecoratorUnfocusedBorderIsColored: false,
      //alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      useInputDecoratorThemeInDialogs: true,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedLabel: false,
      navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedIcon: false,
      navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationBarIndicatorOpacity: 1.00,
      navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedLabel: false,
      navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedIcon: false,
      navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationRailIndicatorOpacity: 1.00,
      navigationRailBackgroundSchemeColor: SchemeColor.surface,
      navigationRailLabelType: NavigationRailLabelType.none,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.merriweather().fontFamily,
  );
}
