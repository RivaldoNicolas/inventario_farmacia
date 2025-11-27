import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

class CrearUsuarioScreen extends StatefulWidget {
  const CrearUsuarioScreen({super.key});

  @override
  State<CrearUsuarioScreen> createState() => _CrearUsuarioScreenState();
}

class _CrearUsuarioScreenState extends State<CrearUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'personal'; // Rol por defecto

  final _usuarioDao = UsuarioDao();

  void _crearUsuario() async {
    if (_formKey.currentState!.validate()) {
      final nombreUsuario = _usuarioController.text;

      // 1. Verificar si el usuario ya existe
      final usuarioExistente = await _usuarioDao.obtenerPorNombreUsuario(
        nombreUsuario,
      );

      if (usuarioExistente != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este nombre de usuario ya está en uso.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Hashear la contraseña
      final passwordBytes = utf8.encode(_passwordController.text);
      final passwordHash = sha256.convert(passwordBytes);

      // 3. Crear el nuevo usuario
      final nuevoUsuario = Usuario(
        nombreUsuario: nombreUsuario,
        passwordHash: passwordHash.toString(),
        rol: _rolSeleccionado,
      );

      // 4. Insertar en la base de datos
      await _usuarioDao.insertar(nuevoUsuario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Usuario / Correo',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (v.length < 6)
                    return 'La contraseña debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Rol del Usuario',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'personal', child: Text('Personal')),
                  DropdownMenuItem(
                    value: 'administrador',
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (valor) {
                  setState(() {
                    _rolSeleccionado = valor!;
                  });
                },
              ),
              const SizedBox(height: 32),
              BotonPrincipal(texto: 'Crear Usuario', onPressed: _crearUsuario),
            ],
          ),
        ),
      ),
    );
  }
}
