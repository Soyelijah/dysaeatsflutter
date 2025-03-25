import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/**
 * CustomButton
 * 
 * Widget de botón personalizado con diferentes variantes de estilo, 
 * animaciones y estados de carga.
 * 
 * Proporciona una interfaz consistente para todos los botones de la aplicación,
 * permitiendo personalizar colores, íconos, y comportamientos.
 */
class CustomButton extends StatelessWidget {
  // Propiedades principales
  final String text;
  final VoidCallback onPressed;
  
  // Personalización visual
  final Color? color;
  final Color? textColor;
  final IconData? icono;
  final bool outlined;
  final bool fullWidth;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  
  // Estados del botón
  final bool isLoading;
  final bool disabled;
  
  // Constructor
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icono,
    this.outlined = false,
    this.fullWidth = true,
    this.height = 48.0,
    this.width,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.isLoading = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener los colores del tema o usar los proporcionados
    final Color buttonColor = color ?? AppTheme.primaryColor;
    final Color buttonTextColor = textColor ?? (outlined ? buttonColor : Colors.white);
    
    // Construir el widget del botón según el estilo (outlined o filled)
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: AnimatedOpacity(
        opacity: disabled ? 0.6 : 1.0,
        duration: AppTheme.animationDuration,
        child: outlined
            ? _buildOutlinedButton(context, buttonColor, buttonTextColor)
            : _buildFilledButton(context, buttonColor, buttonTextColor),
      ),
    );
  }
  
  // Construir botón con relleno
  Widget _buildFilledButton(BuildContext context, Color buttonColor, Color buttonTextColor) {
    return ElevatedButton(
      onPressed: (disabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        elevation: 2,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        disabledForegroundColor: buttonTextColor.withOpacity(0.5),
        disabledBackgroundColor: buttonColor.withOpacity(0.5),
      ),
      child: _buildChildContent(buttonTextColor),
    );
  }
  
  // Construir botón con borde
  Widget _buildOutlinedButton(BuildContext context, Color buttonColor, Color buttonTextColor) {
    return OutlinedButton(
      onPressed: (disabled || isLoading) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor, width: 1.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChildContent(buttonTextColor),
    );
  }
  
  // Construir el contenido del botón (texto, ícono, indicador de carga)
  Widget _buildChildContent(Color textColor) {
    if (isLoading) {
      // Mostrar indicador de carga
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      // Mostrar texto e ícono si está configurado
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 20, color: textColor),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }
}

/**
 * GradientButton
 * 
 * Botón con fondo de degradado para acciones principales o destacadas.
 * Extiende la funcionalidad de CustomButton con un estilo visual más llamativo.
 */
class GradientButton extends StatelessWidget {
  // Propiedades principales
  final String text;
  final VoidCallback onPressed;
  
  // Personalización visual
  final List<Color> gradientColors;
  final Color textColor;
  final IconData? icono;
  final bool fullWidth;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  
  // Estados del botón
  final bool isLoading;
  final bool disabled;
  
  // Constructor
  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [AppTheme.primaryColor, AppTheme.primaryColorDark],
    this.textColor = Colors.white,
    this.icono,
    this.fullWidth = true,
    this.height = 48.0,
    this.width,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.isLoading = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: AnimatedOpacity(
        opacity: disabled ? 0.6 : 1.0,
        duration: AppTheme.animationDuration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (disabled || isLoading) ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: disabled
                      ? gradientColors.map((c) => c.withOpacity(0.5)).toList()
                      : gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                padding: padding,
                child: _buildChildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Construir el contenido del botón (texto, ícono, indicador de carga)
  Widget _buildChildContent() {
    if (isLoading) {
      // Mostrar indicador de carga
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      // Mostrar texto e ícono si está configurado
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 20, color: textColor),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }
}

/**
 * IconButton
 * 
 * Botón circular con ícono para acciones secundarias o compactas.
 * Ideal para acciones como favoritos, compartir, etc.
 */
class CustomIconButton extends StatelessWidget {
  // Propiedades principales
  final IconData icon;
  final VoidCallback onPressed;
  
  // Personalización visual
  final Color? color;
  final Color? iconColor;
  final double size;
  final bool outlined;
  
  // Estados del botón
  final bool isLoading;
  final bool disabled;
  
  // Constructor
  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.iconColor,
    this.size = 48.0,
    this.outlined = false,
    this.isLoading = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener los colores del tema o usar los proporcionados
    final Color buttonColor = color ?? AppTheme.primaryColor;
    final Color buttonIconColor = iconColor ?? (outlined ? buttonColor : Colors.white);
    
    // Construir el widget del botón según el estilo (outlined o filled)
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedOpacity(
        opacity: disabled ? 0.6 : 1.0,
        duration: AppTheme.animationDuration,
        child: outlined
            ? _buildOutlinedIconButton(buttonColor, buttonIconColor)
            : _buildFilledIconButton(buttonColor, buttonIconColor),
      ),
    );
  }
  
  // Construir botón con relleno
  Widget _buildFilledIconButton(Color buttonColor, Color iconColor) {
    return Material(
      color: buttonColor,
      shape: CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: (disabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: _buildIconContent(iconColor),
        ),
      ),
    );
  }
  
  // Construir botón con borde
  Widget _buildOutlinedIconButton(Color buttonColor, Color iconColor) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(
          color: buttonColor,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: (disabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: _buildIconContent(iconColor),
        ),
      ),
    );
  }
  
  // Construir el contenido del botón (ícono o indicador de carga)
  Widget _buildIconContent(Color iconColor) {
    if (isLoading) {
      // Mostrar indicador de carga
      return SizedBox(
        height: size / 3,
        width: size / 3,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    } else {
      // Mostrar ícono
      return Icon(
        icon,
        color: iconColor,
        size: size / 2,
      );
    }
  }
}