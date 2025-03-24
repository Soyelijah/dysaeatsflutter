// Modelo de datos para representar un usuario
class UserModel {
  // Identificador único del usuario
  final String uid;

  // Correo electrónico del usuario
  final String email;

  // Nombre del usuario (opcional)
  final String? name;

  // URL de la foto del usuario (opcional)
  final String? photoUrl;

  // Constructor para inicializar las propiedades del modelo
  UserModel({
    required this.uid, // uid es obligatorio
    required this.email, // email es obligatorio
    this.name, // name es opcional
    this.photoUrl, // photoUrl es opcional
  });

  // Fábrica para crear una instancia de UserModel a partir de datos de Firebase
  factory UserModel.fromFirebaseUser(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'], // Asigna el uid desde los datos proporcionados
      email: data['email'], // Asigna el email desde los datos proporcionados
      name: data['displayName'], // Asigna el nombre desde los datos proporcionados
      photoUrl: data['photoURL'], // Asigna la URL de la foto desde los datos proporcionados
    );
  }
}

// Resumen: Este modelo define una estructura para representar un usuario con propiedades como uid, email, nombre y foto. 
// También incluye un constructor de fábrica para inicializar el modelo a partir de un mapa de datos, 
// como los que se obtienen de Firebase.
