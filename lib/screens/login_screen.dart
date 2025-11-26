import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/dashboard_screen.dart';

// Convertimos LoginScreen a un StatefulWidget para manejar el estado del formulario.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave para identificar y validar nuestro formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para obtener el texto de los campos del formulario.
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instancia de nuestro DAO para interactuar con la base de datos.
  final _usuarioDao = UsuarioDao();

  // Método que se ejecuta al presionar el botón de "Ingresar".
  void _login() async {
    // Primero, validamos que los campos del formulario no estén vacíos.
    if (_formKey.currentState!.validate()) {
      final nombreUsuario = _usuarioController.text;
      final password = _passwordController.text;

      // Buscamos al usuario en la base de datos.
      final usuario = await _usuarioDao.obtenerPorNombreUsuario(nombreUsuario);

      if (usuario != null) {
        // Si el usuario existe, hasheamos la contraseña ingresada para compararla.
        final bytes = utf8.encode(password);
        final hash = sha256.convert(bytes);

        if (hash.toString() == usuario.passwordHash) {
          // ¡Contraseña correcta! Navegamos al Dashboard.
          // Usamos pushReplacement para que el usuario no pueda volver atrás a la pantalla de login.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(usuario: usuario),
            ),
          );
        } else {
          // Contraseña incorrecta.
          _mostrarError('La contraseña es incorrecta.');
        }
      } else {
        // El usuario no existe.
        _mostrarError('El usuario no se encuentra registrado.');
      }
    }
  }

  // Método para mostrar un mensaje de error en un SnackBar.
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_pharmacy, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                const Text(
                  'Inventario Farmacia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario o Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor, ingrese su usuario' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Para ocultar la contraseña.
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Por favor, ingrese su contraseña'
                      : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // Botón ancho
                  ),
                  child: const Text('Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
