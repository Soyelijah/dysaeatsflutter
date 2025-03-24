// Importaciones necesarias para el funcionamiento de la app
import 'package:flutter/material.dart'; // Framework principal de Flutter
import 'package:firebase_core/firebase_core.dart'; // Inicialización de Firebase
import 'package:provider/provider.dart'; // Gestión de estado con Provider
import 'firebase_options.dart'; // Configuración específica de Firebase

// Importaciones de proveedores y pantallas
import 'providers/auth_provider.dart'; // Proveedor de autenticación
import 'screens/login_screen.dart'; // Pantalla de inicio de sesión
import 'screens/home_screen.dart'; // Pantalla principal de la app

// Función principal de la app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de widgets
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Inicializa Firebase con las opciones de la plataforma actual
  runApp(const MyApp()); // Ejecuta la app principal
}

// Clase principal de la app
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor de la clase

  @override
  Widget build(BuildContext context) {
    // Configuración del proveedor de estado
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Crea una instancia del proveedor de autenticación
      child: Consumer<AuthProvider>( // Escucha los cambios en el proveedor
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Oculta la etiqueta de modo debug
            title: 'DysaEats', // Título de la app
            theme: ThemeData(
              primarySwatch: Colors.orange, // Color principal de la app
              fontFamily: 'Roboto', // Fuente predeterminada
            ),
            // Define la pantalla inicial según el estado del usuario
            home: authProvider.user == null ? LoginScreen() : HomeScreen(),
          );
        },
      ),
    );
  }
}
