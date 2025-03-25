import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Servicio central para la inicialización y gestión de Firebase
///
/// Este servicio maneja la configuración de Firebase y proporciona
/// acceso centralizado a las diferentes instancias de los servicios de Firebase.
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  
  // Instancias de los servicios de Firebase
  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;
  
  // Variables de estado
  bool _initialized = false;
  
  // Constructor de fábrica que devuelve la instancia única
  factory FirebaseService() {
    return _instance;
  }
  
  // Constructor privado
  FirebaseService._internal();
  
  /// Inicializa todos los servicios de Firebase
  ///
  /// Debe llamarse antes de usar cualquier servicio de Firebase,
  /// idealmente en el método main() antes de runApp().
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Inicializar Firebase con las opciones específicas de la plataforma
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Inicializar servicios individuales
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      
      // Configuración adicional para Firestore
      if (kDebugMode) {
        // Usar emulador local en modo debug si está disponible
        // firestore.useFirestoreEmulator('localhost', 8080);
        // auth.useAuthEmulator('localhost', 9099);
      }
      
      _initialized = true;
      debugPrint('Firebase inicializado correctamente');
    } catch (e) {
      debugPrint('Error al inicializar Firebase: $e');
      rethrow;
    }
  }
}