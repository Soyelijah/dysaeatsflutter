import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFFFF6600);
  static const Color primaryColorLight = Color(0xFFFF9248);
  static const Color primaryColorDark = Color(0xFFE65100);
  
  // Colores secundarios
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color secondaryColorLight = Color(0xFF64B5F6);
  static const Color secondaryColorDark = Color(0xFF0D47A1);
  
  // Colores neutrales
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  
  // Fuentes
  static const String fontFamily = 'Roboto';
  static const String fontFamilyTitle = 'Poppins';
  
  // Animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  
  // Espaciado
  static const double spacing = 8.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  
  // Radios de borde
  static const double borderRadius = 8.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusLarge = 16.0;
  
  // Sombras
  static List<BoxShadow> get shadowsSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowsMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // Método para obtener el tema completo
  static ThemeData getTheme({bool isDark = false}) {
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: Color(0xFF121212),
            background: Color(0xFF121212),
            error: errorColor,
          )
        : ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
            error: errorColor,
          );
    
    final textTheme = GoogleFonts.getTextTheme(
      fontFamily,
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: isDark ? Color(0xFF1E1E1E) : primaryColor,
        foregroundColor: isDark ? Colors.white : Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 2,
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
        fillColor: isDark ? Color(0xFF2A2A2A) : Colors.white,
        contentPadding: EdgeInsets.all(spacingMedium),
      ),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}