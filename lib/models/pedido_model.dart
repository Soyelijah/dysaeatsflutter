import 'package:cloud_firestore/cloud_firestore.dart';

// Clase que representa un pedido en el sistema
class PedidoModel {
  final String id;
  final String descripcion;
  final String estado;
  final DateTime creadoEn;
  final String userId;

  PedidoModel({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.creadoEn,
    required this.userId,
  });

  // Método de fábrica para crear una instancia de PedidoModel desde Firestore
  factory PedidoModel.fromMap(String id, Map<String, dynamic> data) {
    return PedidoModel(
      id: id,
      descripcion: data['descripcion'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      creadoEn: (data['creadoEn'] != null)
          ? (data['creadoEn'] as Timestamp).toDate()
          : DateTime.now(), // 🔥 Protección contra errores
      userId: data['userId'] ?? '',
    );
  }

  // Método para convertir una instancia de PedidoModel a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion,
      'estado': estado,
      'creadoEn': FieldValue.serverTimestamp(), // 🔥 Se asegura de que Firestore lo guarde correctamente
      'userId': userId,
    };
  }
}
