import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';

class PedidoProvider extends ChangeNotifier {
  List<PedidoModel> _pedidos = [];
  bool _isLoading = false;
  String? _error;
  
  List<PedidoModel> get pedidos => _pedidos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> cargarPedidos(String userId, {String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      QuerySnapshot querySnapshot;
      
      if (role == 'admin') {
        // Administradores ven todos los pedidos
        querySnapshot = await FirebaseFirestore.instance
            .collection('pedidos')
            .orderBy('creadoEn', descending: true)
            .get();
      } else if (role == 'repartidor') {
        // Repartidores ven pedidos pendientes y los asignados a ellos
        querySnapshot = await FirebaseFirestore.instance
            .collection('pedidos')
            .where('repartidorId', isEqualTo: userId)
            .orderBy('creadoEn', descending: true)
            .get();
      } else {
        // Clientes solo ven sus propios pedidos
        querySnapshot = await FirebaseFirestore.instance
            .collection('pedidos')
            .where('userId', isEqualTo: userId)
            .orderBy('creadoEn', descending: true)
            .get();
      }
      
      _pedidos = querySnapshot.docs.map((doc) => 
        PedidoModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}