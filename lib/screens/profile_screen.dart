// Importaciones necesarias para Flutter, Firebase y servicios personalizados
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // Importamos LoginScreen para redirección

// Clase principal para la pantalla de perfil
class ProfileScreen extends StatelessWidget {
  // Usuario actual autenticado
  final User? user = FirebaseAuth.instance.currentUser;

  // Método para obtener el rol del usuario desde Firestore
  Future<String> getUserRole() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    return doc.data()?['role'] ?? 'cliente'; // Retorna 'cliente' si no hay rol definido
  }

  @override
  Widget build(BuildContext context) {
    // Verifica si el usuario está autenticado
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("No se encontró el usuario")), // Mensaje si no hay usuario
      );
    }

    // Construcción de la interfaz principal
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'), // Título de la pantalla
        actions: [
          // Botón para cerrar sesión
          IconButton(
            icon: Icon(Icons.logout), // Ícono de logout
            onPressed: () async {
              await AuthService().signOut(); // Llama al servicio de cierre de sesión

              // ✅ Redirige a la pantalla de login eliminando historial
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: FutureBuilder<String>(
        future: getUserRole(), // Obtiene el rol del usuario
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras se obtiene el rol
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final role = snapshot.data!; // Rol obtenido del snapshot

          // Contenido principal de la pantalla
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Muestra la foto de perfil si está disponible
                if (user!.photoURL != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                    radius: 50,
                  ),
                SizedBox(height: 20), // Espaciado entre elementos
                // Muestra el nombre del usuario o un mensaje si no está disponible
                Text(
                  user!.displayName ?? 'Nombre no disponible',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Muestra el correo electrónico del usuario
                Text(
                  user!.email ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                // Muestra el rol del usuario en un chip
                Chip(
                  label: Text("Rol: $role"),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
