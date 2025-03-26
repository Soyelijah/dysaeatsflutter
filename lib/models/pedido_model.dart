// lib/models/pedido_model.dart (Flutter)

import 'package:cloud_firestore/cloud_firestore.dart';

// Clase que representa un pedido en el sistema
class PedidoModel {
  final String id;
  final String descripcion;
  final String estado;
  final DateTime creadoEn;
  final String userId;
  final String? repartidorId;
  final List<ProductoModel>? productos;
  final double? total;
  final String? metodoPago;
  final UbicacionModel? ubicacionCliente;
  final UbicacionModel? ubicacionRepartidor;
  final DateTime? aceptadoEn;
  final DateTime? entregadoEn;
  final DateTime? canceladoEn;

  PedidoModel({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.creadoEn,
    required this.userId,
    this.repartidorId,
    this.productos,
    this.total,
    this.metodoPago,
    this.ubicacionCliente,
    this.ubicacionRepartidor,
    this.aceptadoEn,
    this.entregadoEn,
    this.canceladoEn,
  });

  // Método de fábrica para crear una instancia de PedidoModel desde Firestore
  factory PedidoModel.fromMap(String id, Map<String, dynamic> data) {
    // Convertir lista de productos si existe
    List<ProductoModel>? productos;
    if (data['productos'] != null) {
      productos = (data['productos'] as List).map((item) => 
        ProductoModel.fromMap(item)).toList();
    }
    
    // Convertir ubicaciones si existen
    UbicacionModel? ubicacionCliente;
    if (data['ubicacionCliente'] != null) {
      ubicacionCliente = UbicacionModel.fromMap(data['ubicacionCliente']);
    }
    
    UbicacionModel? ubicacionRepartidor;
    if (data['ubicacionRepartidor'] != null) {
      final geoPoint = data['ubicacionRepartidor'] as GeoPoint;
      ubicacionRepartidor = UbicacionModel(
        latitude: geoPoint.latitude,
        longitude: geoPoint.longitude,
        direccion: null,
      );
    }

    return PedidoModel(
      id: id,
      descripcion: data['descripcion'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      creadoEn: (data['creadoEn'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      repartidorId: data['repartidorId'],
      productos: productos,
      total: data['total']?.toDouble(),
      metodoPago: data['metodoPago'],
      ubicacionCliente: ubicacionCliente,
      ubicacionRepartidor: ubicacionRepartidor,
      aceptadoEn: data['aceptadoEn'] != null ? (data['aceptadoEn'] as Timestamp).toDate() : null,
      entregadoEn: data['entregadoEn'] != null ? (data['entregadoEn'] as Timestamp).toDate() : null,
      canceladoEn: data['canceladoEn'] != null ? (data['canceladoEn'] as Timestamp).toDate() : null,
    );
  }

  // Método para convertir una instancia de PedidoModel a un mapa para Firestore
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'descripcion': descripcion,
      'estado': estado,
      'creadoEn': FieldValue.serverTimestamp(),
      'userId': userId,
    };
    
    if (repartidorId != null) map['repartidorId'] = repartidorId;
    if (productos != null && productos!.isNotEmpty) {
      map['productos'] = productos!.map((p) => p.toMap()).toList();
    }
    if (total != null) map['total'] = total;
    if (metodoPago != null) map['metodoPago'] = metodoPago;
    if (ubicacionCliente != null) map['ubicacionCliente'] = ubicacionCliente!.toMap();
    
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
    List<ProductoModel>? productos,
    double? total,
    String? metodoPago,
    UbicacionModel? ubicacionCliente,
    UbicacionModel? ubicacionRepartidor,
    DateTime? aceptadoEn,
    DateTime? entregadoEn,
    DateTime? canceladoEn,
  }) {
    return PedidoModel(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      creadoEn: creadoEn ?? this.creadoEn,
      userId: userId ?? this.userId,
      repartidorId: repartidorId ?? this.repartidorId,
      productos: productos ?? this.productos,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      ubicacionCliente: ubicacionCliente ?? this.ubicacionCliente,
      ubicacionRepartidor: ubicacionRepartidor ?? this.ubicacionRepartidor,
      aceptadoEn: aceptadoEn ?? this.aceptadoEn,
      entregadoEn: entregadoEn ?? this.entregadoEn,
      canceladoEn: canceladoEn ?? this.canceladoEn,
    );
  }
}

// Modelo para productos dentro de pedidos
class ProductoModel {
  final String id;
  final String nombre;
  final int cantidad;
  final double precio;
  
  ProductoModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });
  
  factory ProductoModel.fromMap(Map<String, dynamic> data) {
    return ProductoModel(
      id: data['id'] ?? '',
      nombre: data['nombre'] ?? '',
      cantidad: data['cantidad'] ?? 1,
      precio: (data['precio'] ?? 0.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
    };
  }
}

// Modelo para ubicaciones
class UbicacionModel {
  final double latitude;
  final double longitude;
  final String? direccion;
  
  UbicacionModel({
    required this.latitude,
    required this.longitude,
    this.direccion,
  });
  
  factory UbicacionModel.fromMap(Map<String, dynamic> data) {
    // Si viene como GeoPoint
    if (data is GeoPoint) {
      return UbicacionModel(
        latitude: data.latitude,
        longitude: data.longitude,
        direccion: null,
      );
    }
    
    // Si viene como Map
    return UbicacionModel(
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      direccion: data['direccion'],
    );
  }
  
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'latitude': latitude,
      'longitude': longitude,
    };
    
    if (direccion != null) map['direccion'] = direccion;
    
    return map;
  }
}