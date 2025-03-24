// Importación de paquetes necesarios para la autenticación con Firebase, Google y Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Clase que gestiona los servicios de autenticación
class AuthService {
  // Instancia de FirebaseAuth para manejar la autenticación
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instancia de FirebaseFirestore para manejar la base de datos
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para iniciar sesión con Google
  // Este método permite al usuario autenticarse usando su cuenta de Google.
  Future<User?> signInWithGoogle() async {
    // Inicia el flujo de inicio de sesión de Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Si el usuario cancela el inicio de sesión, retorna null
    if (googleUser == null) return null;

    // Obtiene las credenciales de autenticación de Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // Crea un objeto de credenciales para Firebase usando los tokens de Google
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Inicia sesión en Firebase con las credenciales de Google
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    // Si el usuario se autentica correctamente
    if (user != null) {
      // Referencia al documento del usuario en Firestore
      final userDoc = _firestore.collection('users').doc(user.uid);

      try {
        // Verifica si el documento del usuario ya existe
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          // Si no existe, crea un nuevo documento con los datos del usuario
          print("Creando usuario en Firestore...");
          await userDoc.set({
            'uid': user.uid, // Identificador único del usuario
            'name': user.displayName ?? '', // Nombre del usuario
            'email': user.email ?? '', // Correo electrónico del usuario
            'photoURL': user.photoURL ?? '', // URL de la foto del usuario
            'role': 'cliente', // Rol por defecto del usuario
            'createdAt': FieldValue.serverTimestamp(), // Fecha de creación
          });
          print("✅ Usuario guardado en Firestore.");
        } else {
          // Si el documento ya existe, muestra un mensaje de depuración
          print("📂 Usuario ya existe en Firestore.");
        }
      } catch (e) {
        // Manejo de errores al guardar el usuario en Firestore
        print("❌ ERROR al guardar usuario en Firestore: $e");
      }
    }

    // Retorna el usuario autenticado
    return user;
  }

  // Método para cerrar sesión
  // Este método cierra la sesión tanto en Google como en Firebase.
  Future<void> signOut() async {
    // Cierra sesión en Google
    await GoogleSignIn().signOut();
    // Cierra sesión en Firebase
    await _auth.signOut();
  }
}
