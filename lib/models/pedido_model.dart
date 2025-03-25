import 'package:cloud_firestore/cloud_firestore.dart';

// Clase que representa un pedido en el sistema
class PedidoModel {
  final String id;
  final String descripcion;
  final String estado;
  final DateTime creadoEn;
  final String userId;
  final String? repartidorId; // Añadido campo para ID del repartidor

  PedidoModel({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.creadoEn,
    required this.userId,
    this.repartidorId, // Opcional porque un pedido puede no tener repartidor asignado
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
      repartidorId: data['repartidorId'], // Recupera el ID del repartidor si existe
    );
  }

  // Método para convertir una instancia de PedidoModel a un mapa para Firestore
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'descripcion': descripcion,
      'estado': estado,
      'creadoEn': FieldValue.serverTimestamp(), // 🔥 Se asegura de que Firestore lo guarde correctamente
      'userId': userId,
    };
    
    // Solo incluye repartidorId si no es nulo
    if (repartidorId != null) {
      map['repartidorId'] = repartidorId;
    }
    
    return map;
  }
  
  // Método para crear una copia del objeto con algunos cambios
  PedidoModel copyWith({
    String? id,
    String? descripcion,
    String? estado,
    DateTime? creadoEn,
    String? userId,
    String? repartidorId,
  }) {
    return PedidoModel(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
      userId: userId ?? this.userId,
      repartidorId: repartidorId ?? this.repartidorId,
    );
  }
}