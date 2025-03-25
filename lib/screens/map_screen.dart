import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  final String pedidoId;
  final double? latitudDestino;
  final double? longitudDestino;
  final String? direccionDestino;

  const MapScreen({
    Key? key,
    required this.pedidoId,
    this.latitudDestino,
    this.longitudDestino,
    this.direccionDestino,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    // Aquí inicializarías los marcadores y la ruta
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento de Pedido'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-33.4489, -70.6693), // Santiago, Chile por defecto
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dirección de entrega:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.direccionDestino ?? 'No disponible'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}