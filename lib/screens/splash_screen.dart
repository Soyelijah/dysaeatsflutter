import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';
import '../theme/app_theme.dart';
// Usar un alias para evitar conflicto con Firebase Auth
import '../providers/auth_provider.dart' as app_auth;

/**
 * SplashScreen
 * 
 * Pantalla de carga inicial de la aplicación que verifica el estado de
 * autenticación del usuario y redirige a la pantalla correspondiente.
 * 
 * También muestra animaciones y el logo de la aplicación mientras se
 * cargan los recursos necesarios.
 */
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Controlador de animación para los elementos visuales
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Define el tiempo mínimo de visualización del splash
  final splashDuration = Duration(seconds: 3);
  
  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );
    
    // Iniciar animación
    _animationController.forward();
    
    // Iniciar el proceso de verificación de autenticación después de un delay
    Timer(splashDuration, () {
      _checkAuthAndNavigate();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Verificar estado de autenticación y redireccionar según corresponda
  Future<void> _checkAuthAndNavigate() async {
    // Usar el alias app_auth para acceder a tu AuthProvider
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    
    // Esperar a que el estado de autenticación esté listo
    if (auth.isLoading) {
      // Esperar un poco más si la autenticación está en proceso
      await Future.delayed(Duration(milliseconds: 500));
      _checkAuthAndNavigate(); // Verificar nuevamente
      return;
    }
    
    // Obtener usuario actual
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Si no hay usuario autenticado, ir a la pantalla de login
      Navigator.pushReplacementNamed(context, AppRouter.login);
    } else {
      try {
        // Obtener datos adicionales del usuario desde Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data();
          final role = userData?['role'] as String? ?? 'cliente';
          
          // Navegar a la pantalla correspondiente según el rol
          AppRouter.navigateToRoleBasedScreen(context, role);
        } else {
          // Si no hay datos del usuario, ir al home genérico
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      } catch (e) {
        print('Error al obtener datos del usuario: $e');
        // En caso de error, ir al home genérico
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Fondo con degradado de colores
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColorDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "D",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamilyTitle,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Nombre de la aplicación
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    "DysaEats",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamilyTitle,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Eslogan de la aplicación
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    "La comida que amas, en la puerta de tu casa",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 60),
                
                // Indicador de carga
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}