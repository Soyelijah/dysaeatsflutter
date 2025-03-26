import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? telefono;
  final String? direccion;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.telefono,
    this.direccion,
    this.role = 'cliente',
    this.createdAt,
  });

  // Crear una instancia de UserModel a partir de un documento de Firestore
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      photoUrl: data['photoURL'],
      telefono: data['telefono'],
      direccion: data['direccion'],
      role: data['role'] ?? 'cliente',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir el modelo a un mapa para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': photoUrl,
      'telefono': telefono,
      'direccion': direccion,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  // Método para crear una copia del objeto con algunos campos modificados
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? telefono,
    String? direccion,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}