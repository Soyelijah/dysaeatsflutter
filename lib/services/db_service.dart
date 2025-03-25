import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pedido_model.dart';
import '../models/user_model.dart';

class DBService {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Colecciones utilizadas en la base de datos
  final String _usersCollection = 'users';
  final String _pedidosCollection = 'pedidos';
  final String _repartidoresUbicacionCollection = 'repartidores_ubicacion';

  // =============== OPERACIONES CON PEDIDOS ===============

  // Obtener todos los pedidos (para administradores)
  Stream<List<PedidoModel>> getAllPedidos() {
    return _firestore
        .collection(_pedidosCollection)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PedidoModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener pedidos del usuario actual
  Stream<List<PedidoModel>> getPedidosPorUsuario(String userId) {
    return _firestore
        .collection(_pedidosCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PedidoModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener pedidos asignados a un repartidor
  Stream<List<PedidoModel>> getPedidosPorRepartidor(String repartidorId) {
    return _firestore
        .collection(_pedidosCollection)
        .where('repartidorId', isEqualTo: repartidorId)
        .where('estado', whereIn: ['en camino', 'entregado'])
        .orderBy('creadoEn', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PedidoModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener pedidos disponibles para repartidores
  Stream<List<PedidoModel>> getPedidosDisponibles() {
    return _firestore
        .collection(_pedidosCollection)
        .where('estado', isEqualTo: 'pendiente')
        .orderBy('creadoEn')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PedidoModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtener un pedido específico por ID
  Future<PedidoModel?> getPedido(String pedidoId) async {
    final doc = await _firestore.collection(_pedidosCollection).doc(pedidoId).get();
    if (doc.exists) {
      return PedidoModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Crear un nuevo pedido
  Future<String> crearPedido(PedidoModel pedido) async {
    final docRef = await _firestore.collection(_pedidosCollection).add(pedido.toMap());
    return docRef.id;
  }

  // Aceptar un pedido como repartidor
  Future<void> aceptarPedido(String pedidoId, String repartidorId) async {
    await _firestore.collection(_pedidosCollection).doc(pedidoId).update({
      'estado': 'en camino',
      'repartidorId': repartidorId,
    });
    
    // También podemos actualizar la información en la colección de ubicaciones
    await _firestore.collection(_repartidoresUbicacionCollection).doc(repartidorId).set({
      'pedidoActual': pedidoId,
      'enMovimiento': true,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Marcar un pedido como entregado
  Future<void> marcarComoEntregado(String pedidoId) async {
    // Primero obtenemos el pedido para conocer el ID del repartidor
    final pedidoDoc = await _firestore.collection(_pedidosCollection).doc(pedidoId).get();
    if (!pedidoDoc.exists) {
      throw Exception('El pedido no existe');
    }
    
    final repartidorId = pedidoDoc.data()?['repartidorId'];
    
    // Actualizamos el estado del pedido
    await _firestore.collection(_pedidosCollection).doc(pedidoId).update({
      'estado': 'entregado',
    });
    
    // Si hay un repartidor asignado, actualizamos su estado
    if (repartidorId != null) {
      await _firestore.collection(_repartidoresUbicacionCollection).doc(repartidorId).update({
        'pedidoActual': null,
        'enMovimiento': false,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
    }
  }

  // Cancelar un pedido
  Future<void> cancelarPedido(String pedidoId) async {
    await _firestore.collection(_pedidosCollection).doc(pedidoId).update({
      'estado': 'cancelado',
    });
  }

  // =============== OPERACIONES CON USUARIOS ===============

  // Obtener datos de un usuario
  Future<UserModel?> getUsuario(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // Crear o actualizar un usuario
  Future<void> saveUsuario(UserModel usuario) async {
    await _firestore.collection(_usersCollection).doc(usuario.uid).set(
        usuario.toMap(), SetOptions(merge: true));
  }

  // Actualizar el rol de un usuario
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'role': role,
    });
  }

  // Obtener todos los usuarios (para admins)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // =============== OPERACIONES DE UBICACIÓN ===============

  // Actualizar la ubicación de un repartidor
  Future<void> updateRepartidorLocation(
      String repartidorId, double latitude, double longitude) async {
    await _firestore.collection(_repartidoresUbicacionCollection).doc(repartidorId).set({
      'ubicacion': GeoPoint(latitude, longitude),
      'ultimaActualizacion': FieldValue.serverTimestamp(),
      'enMovimiento': true,
    }, SetOptions(merge: true));
  }

  // Obtener la ubicación de un repartidor
  Stream<Map<String, dynamic>?> getRepartidorLocation(String repartidorId) {
    return _firestore
        .collection(_repartidoresUbicacionCollection)
        .doc(repartidorId)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data;
      }
      return null;
    });
  }
}