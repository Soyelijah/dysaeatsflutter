import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
// Importar con alias para evitar conflictos
import 'providers/auth_provider.dart' as app_auth;
import 'providers/pedido_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';

/**
 * Punto de entrada principal de la aplicación
 * 
 * Inicializa Firebase, configura proveedores de estado,
 * establece el tema y configura la navegación.
 */
Future<void> main() async {
  // Asegurar que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación de pantalla (solo vertical)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Firebase usando el servicio centralizado
  await FirebaseService().initialize();
  
  // Iniciar la aplicación
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Configurar proveedores de estado globales usando Provider
    return MultiProvider(
      providers: [
        // Proveedor de autenticación - usando el alias
        ChangeNotifierProvider<app_auth.AuthProvider>(
          create: (_) => app_auth.AuthProvider(),
        ),
        // Proveedor de pedidos
        ChangeNotifierProvider<PedidoProvider>(
          create: (_) => PedidoProvider(),
        ),
        // Proveedor de ubicación
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        // Proveedor de tema
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Obtener el modo actual del tema (claro u oscuro)
          final bool isDarkMode = themeProvider.isDarkMode;
          
          return MaterialApp(
            // Configuración general de la app
            title: 'DysaEats',
            debugShowCheckedModeBanner: false, // Ocultar banner de debug
            
            // Configuración del tema de la aplicación
            theme: AppTheme.getTheme(isDark: false), // Tema claro
            darkTheme: AppTheme.getTheme(isDark: true), // Tema oscuro
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Modo de tema
            
            // Configuración de localización (idioma español por defecto)
            locale: const Locale('es', 'ES'),
            supportedLocales: [
              const Locale('es', 'ES'), // Español
              const Locale('en', 'US'), // Inglés
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Pantalla inicial de carga
            home: SplashScreen(),
            
            // Configuración de rutas
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.splash,
            
            // Comportamiento de scroll
            scrollBehavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
              overscroll: false,
            ),
          );
        },
      ),
    );
  }
}

// Eliminar esta clase de aquí - debe estar solo en providers/auth_provider.dart
// /**
//  * Proveedor de Autenticación
//  * 
//  * Gestiona el estado de autenticación del usuario actual y proporciona
//  * métodos para iniciar sesión, cerrar sesión y obtener información del usuario.
//  */
// class AuthProvider extends ChangeNotifier {
//   ...
// }

/**
 * Proveedor de Tema
 * 
 * Gestiona el modo del tema (claro u oscuro) y proporciona
 * métodos para cambiar entre ellos.
 */
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  // Getter para acceder al modo del tema
  bool get isDarkMode => _isDarkMode;
  
  // Cambiar el modo del tema
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Establecer modo oscuro
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

/**
 * Proveedor de Pedidos
 * 
 * Gestiona el estado de los pedidos del usuario actual y proporciona
 * métodos para crear, actualizar y obtener pedidos.
 */
class PedidoProvider extends ChangeNotifier {
  List<dynamic> _pedidos = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters para acceder al estado
  List<dynamic> get pedidos => _pedidos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Cargar pedidos del usuario actual
  Future<void> cargarPedidos(String userId, {String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // La lógica para cargar pedidos se implementará en un servicio
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/**
 * Proveedor de Ubicación
 * 
 * Gestiona el estado de la ubicación del dispositivo y proporciona
 * métodos para obtener y actualizar la ubicación.
 */
class LocationProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  bool _isTracking = false;
  String? _error;
  
  // Getters para acceder al estado
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isTracking => _isTracking;
  String? get error => _error;
  
  // Iniciar seguimiento de ubicación
  Future<void> startTracking() async {
    _error = null;
    
    try {
      _isTracking = true;
      notifyListeners();
      
      // La lógica para el seguimiento de ubicación se implementará en un servicio
    } catch (e) {
      _error = e.toString();
      _isTracking = false;
    } finally {
      notifyListeners();
    }
  }
  
  // Detener seguimiento de ubicación
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }
  
  // Actualizar ubicación
  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
}