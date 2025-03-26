// lib/services/location_service.dart (Flutter)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pedido_model.dart';

class LocationService {
  // Singleton
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  // Instancias de FirebaseFirestore y Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Variables para el seguimiento
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTrackingEnabled = false;
  String? _currentPedidoId;
  
  // Streams para publicar actualizaciones
  final _locationStreamController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationStreamController.stream;
  
  // Getters de estado
  bool get isTracking => _isTrackingEnabled;
  String? get currentPedidoId => _currentPedidoId;
  
  // Solicitar y verificar permisos de ubicación
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio de ubicación no está habilitado, no podemos obtener la ubicación
      return false;
    }

    // Verificar permiso de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si los permisos están denegados, solicitar permiso
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el usuario niega los permisos, no podemos obtener la ubicación
        return false;
      }
    }
    
    // Si los permisos están permanentemente denegados, no podemos obtener la ubicación
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Si llegamos aquí, se conceden los permisos
    return true;
  }
  
  // Iniciar seguimiento de ubicación
  Future<bool> startTracking({
    String? pedidoId,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    int intervalInSeconds = 5,
  }) async {
    // Verificar permisos
    bool permissionGranted = await checkLocationPermission();
    if (!permissionGranted) {
      return false;
    }
    
    // Verificar si ya estamos haciendo seguimiento
    if (_isTrackingEnabled) {
      return true; // Ya estamos haciendo seguimiento
    }
    
    try {
      // Guardar ID del pedido si se proporciona
      _currentPedidoId = pedidoId;
      
      // Configurar opciones de seguimiento
      LocationSettings locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: Duration(seconds: intervalInSeconds),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'DysaEats - Seguimiento Activo',
          notificationText: 'Estamos compartiendo tu ubicación con el cliente',
          enableWakeLock: true,
        ),
      );
      
      // Iniciar el seguimiento
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings
      ).listen(
        (Position position) {
          // Notificar a los oyentes sobre la nueva posición
          _locationStreamController.add(position);
          
          // Actualizar ubicación en Firestore
          _updateLocationInFirestore(position, pedidoId);
        },
        onError: (error) {
          print('Error en el seguimiento de ubicación: $error');
          stopTracking();
        },
      );
      
      _isTrackingEnabled = true;
      return true;
    } catch (e) {
      print('Error al iniciar el seguimiento: $e');
      return false;
    }
  }
  
  // Detener el seguimiento de ubicación
  Future<void> stopTracking() async {
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _isTrackingEnabled = false;
      
      // Si estábamos siguiendo un pedido, actualizar su estado
      if (_currentPedidoId != null) {
        await _updateTrackingStatusInFirestore(false);
        _currentPedidoId = null;
      }
    } catch (e) {
      print('Error al detener el seguimiento: $e');
    }
  }
  
  // Actualizar ubicación en Firestore
  Future<void> _updateLocationInFirestore(Position position, String? pedidoId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      
      final repartidorRef = _firestore.collection('repartidores_ubicacion').doc(uid);
      
      // Actualizar ubicación del repartidor
      await repartidorRef.set({
        'ubicacion': GeoPoint(position.latitude, position.longitude),
        'velocidad': position.speed,
        'heading': position.heading,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
        'enMovimiento': true,
        'precision': position.accuracy,
        'altitud': position.altitude,
      }, SetOptions(merge: true));
      
      // Si hay un pedido activo, actualizar su ubicación también
      if (pedidoId != null) {
        final pedidoRef = _firestore.collection('pedidos').doc(pedidoId);
        
        await pedidoRef.update({
          'ubicacionRepartidor': GeoPoint(position.latitude, position.longitude),
          'ultimaActualizacionUbicacion': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al actualizar ubicación en Firestore: $e');
    }
  }
  
  // Actualizar estado de seguimiento en Firestore
  Future<void> _updateTrackingStatusInFirestore(bool isTracking) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      
      final repartidorRef = _firestore.collection('repartidores_ubicacion').doc(uid);
      
      await repartidorRef.update({
        'enMovimiento': isTracking,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
        'pedidoActual': isTracking ? _currentPedidoId : null,
      });
    } catch (e) {
      print('Error al actualizar estado de seguimiento: $e');
    }
  }
  
  // Obtener la última ubicación conocida
  Future<Position?> getLastKnownLocation() async {
    try {
      bool permissionGranted = await checkLocationPermission();
      if (!permissionGranted) return null;
      
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('Error al obtener la última ubicación: $e');
      return null;
    }
  }
  
  // Obtener la ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      bool permissionGranted = await checkLocationPermission();
      if (!permissionGranted) return null;
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
    } catch (e) {
      print('Error al obtener la ubicación actual: $e');
      return null;
    }
  }
  
  // Calcular distancia entre dos puntos en kilómetros
  double calculateDistance(double startLatitude, double startLongitude, 
                          double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude, startLongitude, endLatitude, endLongitude
    ) / 1000; // Convertir de metros a kilómetros
  }
  
  // Limpiar recursos al finalizar
  void dispose() {
    stopTracking();
    _locationStreamController.close();
  }
}