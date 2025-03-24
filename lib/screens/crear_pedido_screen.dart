// Importaciones necesarias para la funcionalidad de la pantalla
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pedido_model.dart';
import '../services/db_service.dart';
import 'pedidos_screen.dart';

// Clase principal de la pantalla para crear un pedido
class CrearPedidoScreen extends StatefulWidget {
  @override
  _CrearPedidoScreenState createState() => _CrearPedidoScreenState();
}

// Estado asociado a la pantalla CrearPedidoScreen
class _CrearPedidoScreenState extends State<CrearPedidoScreen> {
  // Clave global para manejar el estado del formulario
  final _formKey = GlobalKey<FormState>();

  // Controlador para manejar el texto ingresado en el campo de descripción
  final TextEditingController _descripcionController = TextEditingController();

  // Indicador para mostrar el estado de carga
  bool _loading = false;

  // Método para guardar un nuevo pedido en la base de datos
  void _guardarPedido() async {
    // Validación del formulario
    if (!_formKey.currentState!.validate()) return;

    // Actualización del estado para mostrar el indicador de carga
    setState(() => _loading = true);

    // Obtención del ID del usuario autenticado
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Creación de un nuevo modelo de pedido
    final pedido = PedidoModel(
      id: '', // ID generado automáticamente por la base de datos
      descripcion: _descripcionController.text.trim(), // Descripción ingresada
      estado: 'pendiente', // Estado inicial del pedido
      creadoEn: DateTime.now(), // Fecha y hora actuales
      userId: userId, // ID del usuario que creó el pedido
    );

    // Llamada al servicio para guardar el pedido en la base de datos
    await DBService().crearPedido(pedido);

    // Actualización del estado para ocultar el indicador de carga
    setState(() => _loading = false);

    // Muestra un mensaje de éxito al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Pedido creado exitosamente")),
    );

    // Navegación a la pantalla de pedidos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PedidosScreen()),
    );
  }

  // Método para construir la interfaz de usuario de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de la aplicación con el título
      appBar: AppBar(
        title: Text("Nuevo Pedido"),
      ),
      // Cuerpo de la pantalla con un formulario
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Espaciado alrededor del formulario
        child: Form(
          key: _formKey, // Asignación de la clave del formulario
          child: Column(
            children: [
              // Campo de texto para ingresar la descripción del pedido
              TextFormField(
                controller: _descripcionController, // Controlador del campo
                decoration: InputDecoration(
                  labelText: "Descripción del pedido", // Etiqueta del campo
                  border: OutlineInputBorder(), // Borde del campo
                ),
                // Validación para asegurarse de que el campo no esté vacío
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa una descripción' : null,
              ),
              SizedBox(height: 20), // Espaciado entre el campo y el botón
              // Botón para crear el pedido o un indicador de carga
              _loading
                  ? CircularProgressIndicator() // Indicador de carga
                  : ElevatedButton(
                      onPressed: _guardarPedido, // Acción al presionar el botón
                      child: Text("Crear Pedido"), // Texto del botón
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
