import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';

// Clase para manejar operaciones de base de datos relacionadas con pedidos
class DBService {
  // Instancia de FirebaseFirestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener pedidos del usuario actual
  // Este método devuelve un Stream de una lista de objetos PedidoModel, filtrando por el ID del usuario
  Stream<List<PedidoModel>> getPedidosPorUsuario(String userId) {
    return _firestore
        .collection('pedidos') // Accede a la colección 'pedidos'
        .where('userId', isEqualTo: userId) // Filtra por el campo 'userId'
        .orderBy('creadoEn', descending: true) // Ordena por fecha de creación en orden descendente
        .snapshots() // Obtiene actualizaciones en tiempo real
        .map((snapshot) => snapshot.docs
            .map((doc) => PedidoModel.fromMap(doc.id, doc.data())) // Convierte cada documento en un PedidoModel
            .toList());
  }

  // Crear nuevo pedido
  // Este método agrega un nuevo documento a la colección 'pedidos' con los datos del modelo PedidoModel
  Future<void> crearPedido(PedidoModel pedido) async {
    await _firestore.collection('pedidos').add(pedido.toMap()); // Convierte el modelo a un mapa y lo guarda
  }
}
