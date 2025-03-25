// Importaciones necesarias para Firebase y Flutter
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart'; // Servicio de autenticación personalizado

// Clase AuthProvider que extiende ChangeNotifier para manejar el estado de autenticación
class AuthProvider extends ChangeNotifier {
  // Instancia del servicio de autenticación
  final AuthService _authService = AuthService();

  // Usuario autenticado actualmente
  User? _user;
  
  // Estado de carga
  bool _isLoading = true;
  
  // Mensaje de error
  String? _error;

  // Getters para obtener el usuario actual
  User? get user => _user;
  
  // Getter para verificar si está cargando
  bool get isLoading => _isLoading;
  
  // Getter para obtener mensaje de error
  String? get error => _error;

  // Constructor que escucha los cambios en el estado de autenticación
  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  // Método privado para manejar los cambios en el estado de autenticación
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser; // Actualiza el usuario actual
    _isLoading = false; // Ya no está cargando
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  // Método para iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    _isLoading = true; // Establecer que está cargando
    _error = null; // Limpiar errores anteriores
    notifyListeners(); // Notificar cambios
    
    try {
      return await _authService.signInWithGoogle(); // Delegar al servicio de autenticación
    } catch (e) {
      _error = e.toString(); // Guardar el mensaje de error
      return null;
    } finally {
      _isLoading = false; // Ya no está cargando
      notifyListeners(); // Notificar cambios
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    _isLoading = true; // Establecer que está cargando
    notifyListeners(); // Notificar cambios
    
    try {
      await _authService.signOut(); // Delegar al servicio de autenticación
    } catch (e) {
      _error = e.toString(); // Guardar el mensaje de error
    } finally {
      _isLoading = false; // Ya no está cargando
      notifyListeners(); // Notificar cambios
    }
  }
}