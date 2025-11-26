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

  // Variable para manejar la visibilidad de la contraseña.
  bool _obscurePassword = true;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header azul con icono y título
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.teal, // Cambiado a color Teal del tema
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    // Icono de medicamento
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medication,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Control de Inventario\nFarmacia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para gestionar medicamentos de forma segura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulario de login
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey, // Usamos la clave del formulario
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Campo de Correo/Usuario
                      TextFormField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          hintText: 'Correo institucional / Usuario',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey.shade600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, ingrese su usuario'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Campo de Contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, ingrese su contraseña'
                            : null,
                      ),

                      const SizedBox(height: 24),

                      // Botón Iniciar Sesión
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login, // Llamamos a tu método _login
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
