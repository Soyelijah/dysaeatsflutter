// lib/screens/pedido_detail_screen.dart (Flutter)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/pedido_model.dart';
import '../models/user_model.dart';
import '../services/db_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/status_badge.dart';

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
  late Stream<DocumentSnapshot> _pedidoStream;
  PedidoModel? _pedido;
  UserModel? _cliente;
  UserModel? _repartidor;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isMapReady = false;
  bool _isLocationEnabled = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  
  // Referencias para mapas
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final LocationService _locationService = LocationService();
  StreamSubscription? _locationSubscription;
  
  // Ubicaciones
  LatLng? _repartidorPosition;
  LatLng? _clientePosition;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar stream para actualizaciones en tiempo real del pedido
    _pedidoStream = FirebaseFirestore.instance
        .collection('pedidos')
        .doc(widget.pedidoId)
        .snapshots();
    
    // Cargar datos iniciales
    _cargarDatos();
    
    // Inicializar servicio de ubicación
    _inicializarUbicacion();
  }
  
  @override
  void dispose() {
    // Limpiar controlador de mapa y suscripción de ubicación
    _mapController?.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }
  
  // Inicializar servicio de ubicación
  Future<void> _inicializarUbicacion() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    // Verificar si estamos autorizados para rastrear ubicación
    bool locationPermission = await _locationService.checkLocationPermission();
    setState(() {
      _isLocationEnabled = locationPermission;
    });
    
    // Si somos repartidor y tenemos permisos, comenzar rastreo
    if (_isRepartidorAsignado() && locationPermission) {
      await _locationService.startTracking(pedidoId: widget.pedidoId);
      
      // Suscribirse a actualizaciones de ubicación
      _locationSubscription = _locationService.locationStream.listen((position) {
        if (mounted) {
          setState(() {
            _repartidorPosition = LatLng(position.latitude, position.longitude);
            _actualizarMapa();
          });
        }
      });
    }
  }
  
  // Verificar si el usuario actual es el repartidor asignado
  bool _isRepartidorAsignado() {
    if (_pedido == null || _currentUser == null) return false;
    return _pedido!.repartidorId == _currentUser!.uid;
  }
  
  // Verificar si el usuario actual es el cliente del pedido
  bool _isCliente() {
    if (_pedido == null || _currentUser == null) return false;
    return _pedido!.userId == _currentUser!.uid;
  }
  
  // Cargar datos iniciales
  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Obtener datos del usuario actual
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _currentUser = await DBService().getUsuario(currentUser.uid);
      }
      
      // Obtener datos iniciales del pedido
      final pedidoDoc = await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .get();
      
      if (!pedidoDoc.exists) {
        setState(() {
          _errorMessage = "El pedido no existe o ha sido eliminado";
          _isLoading = false;
        });
        return;
      }
      
      // Convertir a modelo
      final pedidoData = pedidoDoc.data()!;
      _pedido = PedidoModel.fromMap(pedidoDoc.id, pedidoData);
      
      // Cargar datos del cliente
      _cliente = await DBService().getUsuario(_pedido!.userId);
      
      // Cargar datos del repartidor si existe
      if (_pedido!.repartidorId != null) {
        _repartidor = await DBService().getUsuario(_pedido!.repartidorId!);
      }
      
      // Obtener ubicaciones para el mapa
      await _obtenerUbicaciones();
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      print("Error al cargar datos: $e");
      setState(() {
        _errorMessage = "Error al cargar los datos del pedido";
        _isLoading = false;
      });
    }
  }
  
  // Obtener ubicaciones para el mapa
  Future<void> _obtenerUbicaciones() async {
    try {
      // Obtener ubicación del cliente
      if (_cliente?.direccion != null) {
        // Aquí deberías geocodificar la dirección
        // Por ahora usamos una posición fija de ejemplo
        _clientePosition = LatLng(-33.4489, -70.6693); // Santiago, Chile
      }
      
      // Obtener ubicación del repartidor si existe
      if (_pedido?.repartidorId != null) {
        final ubicacionDoc = await FirebaseFirestore.instance
            .collection('repartidores_ubicacion')
            .doc(_pedido!.repartidorId)
            .get();
        
        if (ubicacionDoc.exists && ubicacionDoc.data()!['ubicacion'] != null) {
          final geoPoint = ubicacionDoc.data()!['ubicacion'] as GeoPoint;
          _repartidorPosition = LatLng(geoPoint.latitude, geoPoint.longitude);
        }
      }
    } catch (e) {
      print("Error al obtener ubicaciones: $e");
    }
  }
  
  // Configurar el mapa
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
      _actualizarMapa();
    });
  }
  
  // Actualizar marcadores y rutas en el mapa
  void _actualizarMapa() {
    if (!_isMapReady) return;
    
    _markers.clear();
    _polylines.clear();
    
    // Agregar marcador del cliente si existe
    if (_clientePosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('cliente'),
          position: _clientePosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Dirección de entrega'),
        ),
      );
    }
    
    // Agregar marcador del repartidor si existe
    if (_repartidorPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('repartidor'),
          position: _repartidorPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Repartidor'),
        ),
      );
    }
    
    // Crear ruta entre repartidor y cliente si ambos existen
    if (_repartidorPosition != null && _clientePosition != null) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('ruta'),
          points: [_repartidorPosition!, _clientePosition!],
          color: Colors.blue,
          width: 5,
        ),
      );
      
      // Ajustar zoom para ver ambos puntos
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _repartidorPosition!.latitude < _clientePosition!.latitude ? 
            _repartidorPosition!.latitude : _clientePosition!.latitude,
          _repartidorPosition!.longitude < _clientePosition!.longitude ? 
            _repartidorPosition!.longitude : _clientePosition!.longitude,
        ),
        northeast: LatLng(
          _repartidorPosition!.latitude > _clientePosition!.latitude ? 
            _repartidorPosition!.latitude : _clientePosition!.latitude,
          _repartidorPosition!.longitude > _clientePosition!.longitude ? 
            _repartidorPosition!.longitude : _clientePosition!.longitude,
        ),
      );
      
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
    // Si solo tenemos la posición del repartidor
    else if (_repartidorPosition != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_repartidorPosition!, 15));
    }
    // Si solo tenemos la posición del cliente
    else if (_clientePosition != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_clientePosition!, 15));
    }
  }
  
  // Aceptar pedido (para repartidores)
  Future<void> _aceptarPedido() async {
    if (_pedido == null || _currentUser == null) return;
    
    setState(() {
      _isActionLoading = true;
    });
    
    try {
      await DBService().aceptarPedido(_pedido!.id, _currentUser!.uid);
      
      // Iniciar rastreo de ubicación
      if (_isLocationEnabled) {
        await _locationService.startTracking(pedidoId: _pedido!.id);
      }
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido aceptado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error al aceptar pedido: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aceptar el pedido'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }
  
  // Marcar pedido como entregado
  Future<void> _marcarComoEntregado() async {
    if (_pedido == null) return;
    
    setState(() {
      _isActionLoading = true;
    });
    
    try {
      await DBService().marcarComoEntregado(_pedido!.id);
      
      // Detener rastreo de ubicación
      await _locationService.stopTracking();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido marcado como entregado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error al marcar pedido como entregado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al marcar el pedido como entregado'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }
  
  // Cancelar pedido
  Future<void> _cancelarPedido() async {
    if (_pedido == null) return;
    
    // Mostrar diálogo de confirmación
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Pedido'),
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
    ) ?? false;
    
    if (!confirmar) return;
    
    setState(() {
      _isActionLoading = true;
    });
    
    try {
      await DBService().cancelarPedido(_pedido!.id);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido cancelado'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("Error al cancelar pedido: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar el pedido'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingView() : _buildBody(),
    );
  }
  
  // Vista de carga
  Widget _buildLoadingView() {
    return Center(
      child: LoadingIndicator(),
    );
  }
  
  // Cuerpo principal
  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _pedidoStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorView(message: "Error al obtener datos en tiempo real");
        }
        
        if (snapshot.connectionState == ConnectionState.waiting && _pedido == null) {
          return _buildLoadingView();
        }
        
        // Actualizar modelo de pedido si hay cambios
        if (snapshot.hasData && snapshot.data!.exists) {
          final newData = snapshot.data!.data() as Map<String, dynamic>;
          _pedido = PedidoModel.fromMap(snapshot.data!.id, newData);
        }
        
        return _buildPedidoContent();
      },
    );
  }
  
  // Vista de error
  Widget _buildErrorView({String? message}) {
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
            message ?? _errorMessage ?? 'Error al cargar el pedido',
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
  
  // Contenido del pedido
  Widget _buildPedidoContent() {
    if (_pedido == null) {
      return _buildErrorView(message: "No se encontró el pedido");
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con estado del pedido
          _buildHeaderCard(),
          
          // Mapa de seguimiento
          if (_pedido!.estado == "en camino")
            _buildMapCard(),
            
          // Información del cliente
          _buildClienteCard(),
          
          // Información del repartidor
          if (_pedido!.repartidorId != null)
            _buildRepartidorCard(),
            
          // Timeline de seguimiento
          _buildTimelineCard(),
          
          // Botones de acción
          _buildActionButtons(),
          
          // Espaciado final
          SizedBox(height: 20),
        ],
      ),
    );
  }
  
  // Tarjeta de cabecera
  Widget _buildHeaderCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(estado: _pedido!.estado),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_pedido!.creadoEn),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // ID del pedido
            Text(
              'Pedido #${_pedido!.id.substring(0, 8)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            
            // Descripción
            Text(
              'Descripción:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _pedido!.descripcion,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            
            // Productos si existen
            if (_pedido!.productos != null && _pedido!.productos!.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Productos:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: _pedido!.productos!.map((producto) => 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${producto.cantidad}x ${producto.nombre}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '\$${(producto.precio * producto.cantidad).toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ).toList(),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${_pedido!.total?.toStringAsFixed(0) ?? "0"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Tarjeta de mapa
  Widget _buildMapCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Seguimiento en tiempo real',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _repartidorPosition ?? _clientePosition ?? LatLng(-33.4489, -70.6693),
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: _isRepartidorAsignado(),
                myLocationButtonEnabled: _isRepartidorAsignado(),
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Tarjeta de cliente
  Widget _buildClienteCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            if (_cliente != null) ...[
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Nombre',
                value: _cliente!.name ?? 'No especificado',
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.phone_android,
                label: 'Teléfono',
                value: _cliente!.telefono ?? 'No especificado',
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Dirección',
                value: _cliente!.direccion ?? 'No especificada',
              ),
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
    );
  }
  
  // Tarjeta de repartidor
  Widget _buildRepartidorCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delivery_dining, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Información del Repartidor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            if (_repartidor != null) ...[
              Row(
                children: [
                  _repartidor!.photoUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_repartidor!.photoUrl!),
                        radius: 24,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 24,
                      ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _repartidor!.name ?? 'Repartidor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _repartidor!.telefono ?? 'No disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isCliente() && _repartidor!.telefono != null)
                    IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        // Aquí se podría implementar la acción de llamada
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
    );
  }
  
  // Timeline de seguimiento
  Widget _buildTimelineCard() {
    return Card(
      margin: EdgeInsets.all(16),
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
              'Estado del Pedido',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            
            // Pedido creado
            _buildTimelineItem(
              icon: Icons.receipt,
              title: 'Pedido creado',
              subtitle: DateFormat('dd/MM HH:mm').format(_pedido!.creadoEn),
              isActive: true,
              isLast: false,
            ),
            
            // Pedido aceptado
            _buildTimelineItem(
              icon: Icons.pedal_bike,
              title: 'Pedido en camino',
              subtitle: _pedido!.estado == 'pendiente'
                ? 'Esperando repartidor'
                : 'Repartidor asignado',
              isActive: _pedido!.estado == 'en camino' || _pedido!.estado == 'entregado',
              isLast: false,
            ),
            
            // Pedido entregado o cancelado
            if (_pedido!.estado == 'cancelado')
              _buildTimelineItem(
                icon: Icons.cancel,
                title: 'Pedido cancelado',
                subtitle: 'El pedido ha sido cancelado',
                isActive: true,
                isLast: true,
                color: Colors.red,
              )
            else
              _buildTimelineItem(
                icon: Icons.check_circle,
                title: 'Pedido entregado',
                subtitle: _pedido!.estado == 'entregado'
                  ? 'Entrega completada'
                  : 'Pendiente de entrega',
                isActive: _pedido!.estado == 'entregado',
                isLast: true,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
  
  // Botones de acción
  Widget _buildActionButtons() {
    // Si no hay usuario actual, no mostrar botones
    if (_currentUser == null || _pedido == null) return SizedBox();
    
    // Verificar rol y estado para mostrar botones apropiados
    if (_currentUser!.role == 'repartidor') {
      // Acciones para repartidores
      if (_pedido!.estado == 'pendiente' && !_isRepartidorAsignado()) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomButton(
            text: 'Aceptar Pedido',
            onPressed: () {
              if (!_isActionLoading) {
                _aceptarPedido();
              }
            },
            color: Colors.green,
            icono: Icons.check,
            isLoading: _isActionLoading,
          ),
        );
      } else if (_pedido!.estado == 'en camino' && _isRepartidorAsignado()) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomButton(
            text: 'Marcar como Entregado',
            onPressed: () {
              if (!_isActionLoading) {
                _marcarComoEntregado();
              }
            },
            color: AppTheme.primaryColor,
            icono: Icons.check_circle,
            isLoading: _isActionLoading,
          ),
        );
      }
    } else if (_currentUser!.role == 'cliente' && _isCliente()) {
      // Acciones para clientes
      if (_pedido!.estado == 'pendiente') {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomButton(
            text: 'Cancelar Pedido',
            onPressed: () {
              if (!_isActionLoading) {
                _cancelarPedido();
              }
            },
            color: Colors.red,
            icono: Icons.cancel,
            isLoading: _isActionLoading,
          ),
        );
      }
    } else if (_currentUser!.role == 'admin') {
      // Acciones para administradores
      if (_pedido!.estado == 'pendiente') {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomButton(
            text: 'Cancelar Pedido',
            onPressed: () {
              if (!_isActionLoading) {
                _cancelarPedido();
              }
            },
            color: Colors.red,
            icono: Icons.cancel,
            isLoading: _isActionLoading,
          ),
        );
      }
    }
    
    // No hay acciones disponibles
    return SizedBox();
  }
  
  // Fila de información genérica
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
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
  
  // Elemento de timeline
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isLast,
    Color color = Colors.blue,
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
                color: isActive ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? color : Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? color : Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
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
}