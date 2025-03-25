import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/pedido_model.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';
import '../routes/app_router.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

/**
 * Pantalla de Detalle de Pedido
 * 
 * Muestra información detallada de un pedido específico:
 * - Estado y tiempos
 * - Descripción del pedido
 * - Información de cliente/repartidor
 * - Opciones para actualizar el estado según el rol
 * - Línea de tiempo con el progreso del pedido
 */
class PedidoDetailScreen extends StatefulWidget {
  final String pedidoId;
  
  const PedidoDetailScreen({
    Key? key,
    required this.pedidoId,
  }) : super(key: key);

  @override
  _PedidoDetailScreenState createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  // Variables de estado
  late Future<PedidoModel?> _pedidoFuture;
  UserModel? _cliente;
  UserModel? _repartidor;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    
    // Iniciar carga de datos
    _pedidoFuture = _cargarPedido();
    _cargarUsuarioActual();
  }
  
  // Cargar datos del pedido desde Firestore
  Future<PedidoModel?> _cargarPedido() async {
    try {
      // Referencia al documento del pedido
      final pedidoRef = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId);
          
      // Obtener documento
      final pedidoDoc = await pedidoRef.get();
      
      if (!pedidoDoc.exists) {
        setState(() {
          _errorMessage = 'El pedido no existe o ha sido eliminado';
        });
        return null;
      }
      
      // Convertir documento a modelo
      final pedidoData = pedidoDoc.data()!;
      final pedido = PedidoModel.fromMap(pedidoDoc.id, pedidoData);
      
      // Cargar datos del cliente
      await _cargarCliente(pedido.userId);
      
      // Si hay repartidor asignado, cargar sus datos
      if (pedido.repartidorId != null && pedido.repartidorId!.isNotEmpty) {
        await _cargarRepartidor(pedido.repartidorId!);
      }
      
      return pedido;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el pedido: $e';
      });
      return null;
    }
  }
  
  // Cargar datos del cliente
  Future<void> _cargarCliente(String userId) async {
    try {
      final clienteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
          
      final clienteDoc = await clienteRef.get();
      
      if (clienteDoc.exists) {
        final clienteData = clienteDoc.data()!;
        setState(() {
          _cliente = UserModel(
            uid: clienteDoc.id,
            email: clienteData['email'] ?? '',
            name: clienteData['name'],
            photoUrl: clienteData['photoURL'],
          );
        });
      }
    } catch (e) {
      print('Error al cargar datos del cliente: $e');
    }
  }
  
  // Cargar datos del repartidor
  Future<void> _cargarRepartidor(String repartidorId) async {
    try {
      final repartidorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(repartidorId);
          
      final repartidorDoc = await repartidorRef.get();
      
      if (repartidorDoc.exists) {
        final repartidorData = repartidorDoc.data()!;
        setState(() {
          _repartidor = UserModel(
            uid: repartidorDoc.id,
            email: repartidorData['email'] ?? '',
            name: repartidorData['name'],
            photoUrl: repartidorData['photoURL'],
          );
        });
      }
    } catch (e) {
      print('Error al cargar datos del repartidor: $e');
    }
  }
  
  // Cargar datos del usuario actual
  Future<void> _cargarUsuarioActual() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
            
        final userDoc = await userRef.get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _currentUser = UserModel(
              uid: user.uid,
              email: user.email ?? '',
              name: userData['name'],
              photoUrl: userData['photoURL'],
            );
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario actual: $e');
    }
  }
  
  // Aceptar pedido (para repartidores)
  Future<void> _aceptarPedido(PedidoModel pedido) async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await DBService().aceptarPedido(pedido.id, _currentUser!.uid);
      
      // Recargar datos del pedido
      setState(() {
        _pedidoFuture = _cargarPedido();
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido aceptado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al aceptar el pedido: $e';
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Marcar pedido como entregado
  Future<void> _marcarComoEntregado(String pedidoId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await DBService().marcarComoEntregado(pedidoId);
      
      // Recargar datos del pedido
      setState(() {
        _pedidoFuture = _cargarPedido();
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido marcado como entregado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al actualizar el pedido: $e';
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Cancelar pedido (para clientes o administradores)
  Future<void> _cancelarPedido(String pedidoId) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar pedido'),
        content: Text('¿Estás seguro de que deseas cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Actualizar el estado en Firestore
      final pedidoRef = FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId);
          
      await pedidoRef.update({
        'estado': 'cancelado'
      });
      
      // Recargar datos del pedido
      setState(() {
        _pedidoFuture = _cargarPedido();
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido cancelado'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cancelar el pedido: $e';
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Formatear fecha para mostrar
  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
  
  // Obtener color y etiqueta según el estado del pedido
  Map<String, dynamic> _getEstadoInfo(String estado) {
    switch (estado) {
      case 'pendiente':
        return {
          'color': Colors.amber,
          'texto': 'Pendiente',
          'icono': Icons.hourglass_empty,
        };
      case 'en camino':
        return {
          'color': Colors.blue,
          'texto': 'En camino',
          'icono': Icons.directions_bike,
        };
      case 'entregado':
        return {
          'color': Colors.green,
          'texto': 'Entregado',
          'icono': Icons.check_circle,
        };
      case 'cancelado':
        return {
          'color': Colors.red,
          'texto': 'Cancelado',
          'icono': Icons.cancel,
        };
      default:
        return {
          'color': Colors.grey,
          'texto': estado,
          'icono': Icons.help_outline,
        };
    }
  }
  
  // Navegar a la pantalla de mapa
  void _navegarAMapa(PedidoModel pedido) {
    // Verificar que tengamos dirección de entrega
    if (_cliente == null || _cliente!.direccion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se encontró la dirección de entrega'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Navegar a la pantalla de mapa
    Navigator.pushNamed(
      context,
      AppRouter.map,
      arguments: {
        'pedidoId': pedido.id,
        'direccionDestino': _cliente!.direccion,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<PedidoModel?>(
        future: _pedidoFuture,
        builder: (context, snapshot) {
          // Mostrar indicador de carga mientras se cargan los datos
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          
          // Mostrar mensaje de error si ocurrió algún problema
          if (snapshot.hasError || _errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Error al cargar el pedido',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'Volver',
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            );
          }
          
          // Mostrar mensaje si no se encontró el pedido
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se encontró el pedido',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'Volver',
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            );
          }
          
          // Si tenemos datos, mostrar el detalle del pedido
          final pedido = snapshot.data!;
          final estadoInfo = _getEstadoInfo(pedido.estado);
          
          return Stack(
            children: [
              // Contenido principal
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de información general
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Estado del pedido
                            Row(
                              children: [
                                Icon(
                                  estadoInfo['icono'],
                                  color: estadoInfo['color'],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Estado: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: estadoInfo['color'].withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    estadoInfo['texto'],
                                    style: TextStyle(
                                      color: estadoInfo['color'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            
                            // Fecha de creación
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Fecha: ${_formatearFecha(pedido.creadoEn)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Descripción del pedido
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pedido.descripcion,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Información del cliente
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Cliente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            // Detalles del cliente
                            if (_cliente != null) ...[
                              _buildInfoRow(
                                icono: Icons.person,
                                titulo: 'Nombre',
                                valor: _cliente!.name ?? 'No especificado',
                              ),
                              SizedBox(height: 8),
                              _buildInfoRow(
                                icono: Icons.email,
                                titulo: 'Email',
                                valor: _cliente!.email,
                              ),
                              if (_cliente!.telefono != null) ...[
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  icono: Icons.phone,
                                  titulo: 'Teléfono',
                                  valor: _cliente!.telefono!,
                                ),
                              ],
                              if (_cliente!.direccion != null) ...[
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  icono: Icons.location_on,
                                  titulo: 'Dirección',
                                  valor: _cliente!.direccion!,
                                ),
                              ],
                            ] else
                              Text(
                                'No se encontró información del cliente',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Información del repartidor (si existe)
                    if (pedido.repartidorId != null && pedido.repartidorId!.isNotEmpty) ...[
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información del Repartidor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              
                              // Detalles del repartidor
                              if (_repartidor != null) ...[
                                Row(
                                  children: [
                                    if (_repartidor!.photoUrl != null)
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(_repartidor!.photoUrl!),
                                        radius: 20,
                                      )
                                    else
                                      CircleAvatar(
                                        child: Icon(Icons.person),
                                        radius: 20,
                                      ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _repartidor!.name ?? 'Repartidor',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_repartidor!.telefono != null)
                                            Text(
                                              _repartidor!.telefono!,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Botón para llamar si tenemos el teléfono
                                    if (_repartidor!.telefono != null)
                                      IconButton(
                                        icon: Icon(
                                          Icons.phone,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: () {
                                          // Lanzar acción para llamar
                                          // Uri.parse('tel:${_repartidor!.telefono}')
                                        },
                                      ),
                                  ],
                                ),
                              ] else
                                Text(
                                  'No se encontró información del repartidor',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    
                    // Línea de tiempo del pedido
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seguimiento del Pedido',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Estado: Creado
                            _buildTimelineItem(
                              titulo: 'Pedido creado',
                              fecha: _formatearFecha(pedido.creadoEn),
                              icono: Icons.receipt,
                              color: Colors.green,
                              isCompleted: true,
                              isLast: false,
                            ),
                            
                            // Estado: En camino
                            _buildTimelineItem(
                              titulo: 'Pedido aceptado',
                              fecha: pedido.estado == 'pendiente'
                                  ? 'Esperando repartidor'
                                  : 'Repartidor asignado',
                              icono: Icons.directions_bike,
                              color: Colors.blue,
                              isCompleted: pedido.estado == 'en camino' || pedido.estado == 'entregado',
                              isLast: false,
                            ),
                            
                            // Estado: Entregado o Cancelado
                            if (pedido.estado == 'cancelado')
                              _buildTimelineItem(
                                titulo: 'Pedido cancelado',
                                fecha: 'El pedido ha sido cancelado',
                                icono: Icons.cancel,
                                color: Colors.red,
                                isCompleted: true,
                                isLast: true,
                              )
                            else
                              _buildTimelineItem(
                                titulo: 'Pedido entregado',
                                fecha: pedido.estado == 'entregado'
                                    ? 'Entrega completada'
                                    : 'Pendiente',
                                icono: Icons.check_circle,
                                color: Colors.green,
                                isCompleted: pedido.estado == 'entregado',
                                isLast: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Espacio adicional para el botón flotante
                    SizedBox(height: 80),
                  ],
                ),
              ),
              
              // Botones de acción según el rol y estado del pedido
              if (_currentUser != null && !_isLoading)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildActionButtons(pedido),
                ),
                
              // Indicador de carga
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  // Widget para mostrar filas de información
  Widget _buildInfoRow({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Widget para timeline
  Widget _buildTimelineItem({
    required String titulo,
    required String fecha,
    required IconData icono,
    required Color color,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: Colors.white,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? color : Colors.grey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                fecha,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              SizedBox(height: isLast ? 0 : 20),
            ],
          ),
        ),
      ],
    );
  }
  
  // Costruir botones de acción según el rol y estado
  Widget _buildActionButtons(PedidoModel pedido) {
    // Si no hay usuario actual, no mostrar botones
    if (_currentUser == null) return SizedBox();
    
    // Determinar qué botones mostrar según el rol y estado
    if (_currentUser!.role == 'repartidor') {
      // Acciones para repartidores
      if (pedido.estado == 'pendiente' && (pedido.repartidorId == null || pedido.repartidorId!.isEmpty)) {
        return CustomButton(
          text: 'Aceptar Pedido',
          onPressed: () => _aceptarPedido(pedido),
          color: Colors.green,
          icono: Icons.check,
        );
      } else if (pedido.estado == 'en camino' && pedido.repartidorId == _currentUser!.uid) {
        return Column(
          children: [
            CustomButton(
              text: 'Ver Mapa',
              onPressed: () => _navegarAMapa(pedido),
              color: AppTheme.primaryColor,
              icono: Icons.map,
            ),
            SizedBox(height: 8),
            CustomButton(
              text: 'Marcar como Entregado',
              onPressed: () => _marcarComoEntregado(pedido.id),
              color: Colors.green,
              icono: Icons.check_circle,
            ),
          ],
        );
      }
    } else if (_currentUser!.role == 'cliente' && pedido.userId == _currentUser!.uid) {
      // Acciones para clientes
      if (pedido.estado == 'pendiente') {
        return CustomButton(
          text: 'Cancelar Pedido',
          onPressed: () => _cancelarPedido(pedido.id),
          color: Colors.red,
          icono: Icons.cancel,
        );
      } else if (pedido.estado == 'en camino') {
        return CustomButton(
          text: 'Seguir Pedido',
          onPressed: () => _navegarAMapa(pedido),
          color: AppTheme.primaryColor,
          icono: Icons.map,
        );
      }
    } else if (_currentUser!.role == 'admin') {
      // Acciones para administradores
      if (pedido.estado == 'pendiente') {
        return CustomButton(
          text: 'Cancelar Pedido',
          onPressed: () => _cancelarPedido(pedido.id),
          color: Colors.red,
          icono: Icons.cancel,
        );
      } else if (pedido.estado == 'en camino') {
        return CustomButton(
          text: 'Seguir Pedido',
          onPressed: () => _navegarAMapa(pedido),
          color: AppTheme.primaryColor,
          icono: Icons.map,
        );
      }
    }
    
    // Si no hay acciones disponibles, mostrar botón para volver
    return CustomButton(
      text: 'Volver',
      onPressed: () => Navigator.pop(context),
      color: Colors.grey,
      icono: Icons.arrow_back,
    );
  }
}