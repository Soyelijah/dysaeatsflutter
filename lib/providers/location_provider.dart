import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  bool _isTracking = false;
  String? _error;
  
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isTracking => _isTracking;
  String? get error => _error;
  
  Future<void> startTracking() async {
    _error = null;
    
    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Se requieren permisos de ubicación';
          notifyListeners();
          return;
        }
      }
      
      _isTracking = true;
      notifyListeners();
      
      // Iniciar seguimiento de ubicación
      Geolocator.getPositionStream().listen((Position position) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        notifyListeners();
      });
      
    } catch (e) {
      _error = e.toString();
      _isTracking = false;
    } finally {
      notifyListeners();
    }
  }
  
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }
  
  void updateLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }
}