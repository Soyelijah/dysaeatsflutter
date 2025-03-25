import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importación de pantallas
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/pedidos_screen.dart';
import '../screens/crear_pedido_screen.dart';
import '../screens/pedido_detail_screen.dart';
import '../screens/repartidor_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/map_screen.dart';

/**
 * Clase AppRouter
 * 
 * Gestiona todas las rutas de la aplicación y la navegación entre pantallas.
 * Implementa rutas con nombre para facilitar la navegación y la gestión de historial.
 * Incluye manejo de autenticación y autorización basada en roles.
 */
class AppRouter {
  // Definición de rutas con nombre para toda la aplicación
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String pedidos = '/pedidos';
  static const String crearPedido = '/pedidos/crear';
  static const String detallePedido = '/pedidos/detalle';
  static const String repartidorDashboard = '/repartidor';
  static const String adminDashboard = '/admin';
  static const String map = '/map';
  
  // Método para generar rutas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extraer argumentos de la ruta
    final args = settings.arguments;
    
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
        
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
        
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
        
      case pedidos:
        return MaterialPageRoute(builder: (_) => PedidosScreen());
        
      case crearPedido:
        return MaterialPageRoute(builder: (_) => CrearPedidoScreen());
        
      case detallePedido:
        // Verificar que tengamos el ID del pedido como argumento
        if (args is Map<String, dynamic> && args.containsKey('pedidoId')) {
          return MaterialPageRoute(
            builder: (_) => PedidoDetailScreen(pedidoId: args['pedidoId'])
          );
        }
        // Si no tenemos el ID, redirigir a la lista de pedidos
        return MaterialPageRoute(builder: (_) => PedidosScreen());
        
      case repartidorDashboard:
        return MaterialPageRoute(builder: (_) => RepartidorScreen());
        
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => AdminScreen());
        
      case map:
        // Verificar argumentos para el mapa (coordenadas, dirección, etc.)
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => MapScreen(
              pedidoId: args['pedidoId'],
              latitudDestino: args['latitudDestino'],
              longitudDestino: args['longitudDestino'],
              direccionDestino: args['direccionDestino'],
            )
          );
        }
        // Si no tenemos argumentos válidos, volver a la pantalla anterior
        return MaterialPageRoute(builder: (_) => HomeScreen());
        
      default:
        // Ruta no encontrada, mostrar error
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /**
   * Verifica si el usuario está autenticado y redirige según sea necesario
   * 
   * @param context Contexto de la aplicación
   * @returns Ruta inicial apropiada según el estado de autenticación
   */
  static String checkAuthStatus(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Usuario no autenticado, redirigir al login
      return login;
    } else {
      // Usuario autenticado, redirigir al home
      return home;
    }
  }
  
  /**
   * Navega a la ruta apropiada basada en el rol del usuario
   * 
   * @param context Contexto de la aplicación
   * @param role Rol del usuario (cliente, repartidor, admin)
   */
  static void navigateToRoleBasedScreen(BuildContext context, String role) {
    switch (role) {
      case 'cliente':
        Navigator.pushNamedAndRemoveUntil(
          context, 
          home, 
          (route) => false
        );
        break;
      case 'repartidor':
        Navigator.pushNamedAndRemoveUntil(
          context, 
          repartidorDashboard, 
          (route) => false
        );
        break;
      case 'admin':
        Navigator.pushNamedAndRemoveUntil(
          context, 
          adminDashboard, 
          (route) => false
        );
        break;
      default:
        // Si no reconocemos el rol, ir al home genérico
        Navigator.pushNamedAndRemoveUntil(
          context, 
          home, 
          (route) => false
        );
        break;
    }
  }
}