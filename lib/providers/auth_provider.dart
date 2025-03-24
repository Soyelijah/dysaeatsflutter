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

  // Getter para obtener el usuario actual
  User? get user => _user;

  // Constructor que escucha los cambios en el estado de autenticación
  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  // Método privado para manejar los cambios en el estado de autenticación
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser; // Actualiza el usuario actual
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  // Método para iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    return await _authService.signInWithGoogle(); // Delegar al servicio de autenticación
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut(); // Delegar al servicio de autenticación
  }
}
