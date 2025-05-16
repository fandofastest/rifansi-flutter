import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FigmaColors {
  const FigmaColors();

  static const Color primary = Color(0xffff6200);
  static const Color primarycontainer = Color(0xffffe0cc);
  static const Color white = Color(0xffffffff);
  static const Color abu = Color(0xff6b6a69);
  static const Color hitam = Color(0xff1a1a1a);
  static const Color error = Color(0xffff0000);
  static const Color secondary = Color(0xffffb300);
  static const Color background = Color(0xfffff6f2);
  static const Color done = Color(0xff00c441);
  static const Color abu2 = Color(0xffa7a7a6);
}

class FigmaTextStyles {
  const FigmaTextStyles();

  TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-ExtraBold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    height: 32 / 32,
    letterSpacing: 0,
  );

  TextStyle get headlineMedium => const TextStyle(
    fontSize: 24,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Bold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    height: 24 / 24,
    letterSpacing: 0,
  );

  TextStyle get headlineSmall => const TextStyle(
    fontSize: 20,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Bold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    height: 20 / 20,
    letterSpacing: 0,
  );

  TextStyle get tittlemedium => const TextStyle(
    fontSize: 16,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Bold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    height: 20 / 16,
    letterSpacing: 0,
  );

  TextStyle get tittlesmall => const TextStyle(
    fontSize: 12,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-SemiBold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    height: 12 / 12,
    letterSpacing: 0,
  );

  TextStyle get bodylarge => const TextStyle(
    fontSize: 14,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Regular',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    height: 24 / 14,
    letterSpacing: 0,
  );

  TextStyle get bodymedium => const TextStyle(
    fontSize: 12,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Medium',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    height: 20 / 12,
    letterSpacing: 0,
  );

  TextStyle get bodysmall => const TextStyle(
    fontSize: 10,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Regular',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    height: 20 / 10,
    letterSpacing: 0,
  );

  TextStyle get label => const TextStyle(
    fontSize: 8,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-Regular',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
    height: 8 / 8,
    letterSpacing: 0,
  );

  TextStyle get tittlelarge => const TextStyle(
    fontSize: 14,
    decoration: TextDecoration.none,
    fontFamily: 'DMSans-SemiBold',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    height: 14 / 14,
    letterSpacing: 0,
  );
}

final figmaTextStyles = FigmaTextStyles();
final figmaColors = FigmaColors();

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFF00BCD4);
  
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: FigmaColors.primary,
    colorScheme: ColorScheme.light(
      primary: FigmaColors.primary,
      secondary: FigmaColors.secondary,
      error: FigmaColors.error,
      background: FigmaColors.background,
      surface: FigmaColors.white,
    ),
    scaffoldBackgroundColor: FigmaColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: FigmaColors.primary,
      foregroundColor: FigmaColors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        color: FigmaColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: FigmaColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FigmaColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.abu2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.abu2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: GoogleFonts.dmSansTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: FigmaColors.primary,
    colorScheme: ColorScheme.dark(
      primary: FigmaColors.primary,
      secondary: FigmaColors.secondary,
      error: FigmaColors.error,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: FigmaColors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        color: FigmaColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: FigmaColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.abu2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.abu2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: FigmaColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
  );
} 