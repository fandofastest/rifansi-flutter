import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class AppTheme {
  // AppTheme colors (priority colors - these take precedence)
  static const Color primary = Color(0xffff6200);
  static const Color secondary = Color(0xffffb300);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xffff6200);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFF9E9E9E);
  static const Color hitam = Color(0xFF000000);
  static const Color abu = Color(0xFF9E9E9E);

  // Additional colors from FigmaColors (non-conflicting)
  static const Color primarycontainer = Color(0xffffe0cc);
  static const Color white = Color(0xffffffff);
  static const Color done = Color(0xff00c441);
  static const Color abu2 = Color(0xffa7a7a6);

  // Legacy color names for backward compatibility
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color accentColor = warning;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color backgroundColor = background;
  static const Color surfaceColor = surface;
  static const Color textPrimaryColor = textPrimary;
  static const Color textSecondaryColor = textPrimary;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      error: error,
      background: background,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        color: white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: abu2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: abu2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: GoogleFonts.dmSansTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      error: error,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: white,
      elevation: 0,
      titleTextStyle: GoogleFonts.dmSans(
        color: white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
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
        borderSide: BorderSide(color: abu2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: abu2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
  );
}

// Backward compatibility - create aliases for FigmaColors
class FigmaColors {
  static const Color primary = AppTheme.primary;
  static const Color primarycontainer = AppTheme.primarycontainer;
  static const Color white = AppTheme.white;
  static const Color abu = AppTheme.abu;
  static const Color hitam = AppTheme.hitam;
  static const Color error = AppTheme.error;
  static const Color secondary = AppTheme.secondary;
  static const Color background = AppTheme.background;
  static const Color done = AppTheme.done;
  static const Color abu2 = AppTheme.abu2;
}

final figmaColors = FigmaColors();
