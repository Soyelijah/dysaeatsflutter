// Importaciones necesarias para la funcionalidad de la pantalla
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';
import '../models/pedido_model.dart';

// Clase principal de la pantalla de pedidos
class PedidosScreen extends StatelessWidget {
  // Obtiene el ID del usuario actual desde Firebase Authentication
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // Construcción de la interfaz de usuario
    return Scaffold(
      appBar: AppBar(
        // Título de la pantalla
        title: Text('Mis Pedidos'),
      ),
      body: StreamBuilder<List<PedidoModel>>(
        // Obtiene los pedidos del usuario desde el servicio de base de datos
        stream: DBService().getPedidosPorUsuario(userId),
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras se obtienen los datos
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Lista de pedidos obtenida del snapshot
          final pedidos = snapshot.data!;

          // Muestra un mensaje si no hay pedidos
          if (pedidos.isEmpty) {
            return Center(child: Text("No tienes pedidos aún."));
          }

          // Construye una lista de pedidos
          return ListView.builder(
            itemCount: pedidos.length, // Número de pedidos
            itemBuilder: (context, index) {
              final pedido = pedidos[index]; // Pedido actual
              return ListTile(
                // Descripción del pedido
                title: Text(pedido.descripcion),
                // Estado del pedido
                subtitle: Text("Estado: ${pedido.estado}"),
                // Fecha de creación del pedido
                trailing: Text("${pedido.creadoEn.day}/${pedido.creadoEn.month}"),
              );
            },
          );
        },
      ),
    );
  }
}
