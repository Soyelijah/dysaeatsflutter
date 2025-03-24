// Importación de Flutter para construir la interfaz de usuario
import 'package:flutter/material.dart';
// Importación de Firebase Auth para manejar la autenticación
import 'package:firebase_auth/firebase_auth.dart';
// Importación del servicio de autenticación personalizado
import '../services/auth_service.dart';
// Importación de la pantalla de perfil
import 'profile_screen.dart';
// Importación de la pantalla de inicio de sesión
import 'login_screen.dart'; // 👈 nuevo import
import 'pedidos_screen.dart'; // 👈 Importar la pantalla de pedidos
import 'crear_pedido_screen.dart'; // 👈 nuevo import

// Clase principal de la pantalla de inicio
class HomeScreen extends StatelessWidget {
  // Obtiene el usuario actual autenticado desde Firebase
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Verifica si el usuario está autenticado
    if (user == null) {
      // Muestra un mensaje si no hay usuario autenticado
      return Scaffold(
        body: Center(child: Text("No se encontró el usuario")), // Mensaje de error
      );
    }

    return Scaffold(
      // Barra de aplicación con título y botones de acciones
      appBar: AppBar(
        title: Text('DysaEats - Inicio'), // Título de la barra de aplicación
        actions: [
          IconButton(
            icon: Icon(Icons.person), // Icono para navegar al perfil
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()), // Navega a la pantalla de perfil
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout), // Icono de cierre de sesión
            onPressed: () async {
              await AuthService().signOut(); // Llama al servicio para cerrar sesión

              // Redirige al login eliminando el historial de navegación
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()), // Navega a la pantalla de inicio de sesión
                (route) => false, // Elimina todas las rutas anteriores
              );
            },
          ),
        ],
      ),
      // Cuerpo principal de la pantalla
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos verticalmente
          children: [
            // Muestra la foto de perfil del usuario si está disponible
            if (user?.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!), // Imagen de perfil del usuario
                radius: 40, // Radio del avatar
              ),
            SizedBox(height: 16), // Espaciado entre elementos
            // Muestra el nombre del usuario o "Usuario" si no está disponible
            Text(
              'Hola, ${user?.displayName ?? "Usuario"}!', // Saludo personalizado
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Estilo del texto
            ),
            SizedBox(height: 8), // Espaciado entre elementos
            // Muestra el correo electrónico del usuario
            Text(
              user?.email ?? '', // Correo electrónico del usuario
              style: TextStyle(fontSize: 16), // Estilo del texto
            ),
            SizedBox(height: 16), // Espaciado entre elementos
            ElevatedButton(
              // Botón para navegar a la pantalla de pedidos
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PedidosScreen()), // Navega a la pantalla de pedidos
                );
              },
              child: Text("Ver Mis Pedidos"), // Texto del botón
            ),
            SizedBox(height: 16), // Espaciado entre botones
            ElevatedButton(
              // Botón para navegar a la pantalla de creación de pedidos
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CrearPedidoScreen()), // Navega a la pantalla de creación de pedidos
                );
              },
              child: Text("📦 Crear Nuevo Pedido"), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }
}
