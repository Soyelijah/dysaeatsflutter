// Nuevo diseño moderno y profesional para DysaEats Flutter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Colores principales
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color primaryColorDark = Color(0xFF004999);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color textColor = Color(0xFF1F2937);

  // Tipografías
  static const String fontFamily = 'Roboto';
  static const String fontFamilyTitle = 'Poppins';

  // Estilo general
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // Espaciado y bordes
  static const double spacing = 8.0;
  static const double spacingMedium = 16.0;
  static const double borderRadius = 12.0;

  // Sombras
  static const List<BoxShadow> shadowsMedium = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  // Tema completo
  static ThemeData getTheme({bool isDark = false}) {
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            background: Color(0xFF121212),
            surface: Color(0xFF1E1E1E),
            error: errorColor,
          )
        : ColorScheme.light(
            primary: primaryColor,
            background: backgroundColor,
            surface: surfaceColor,
            error: errorColor,
          );

    final textTheme = GoogleFonts.poppinsTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        elevation: 1,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.all(spacingMedium),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
