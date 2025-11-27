import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  late String _rolSeleccionado;

  final _usuarioDao = UsuarioDao();

  @override
  void initState() {
    super.initState();
    _rolSeleccionado = widget.usuario.rol;
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      String nuevoPasswordHash = widget.usuario.passwordHash;

      // Si se ingresó una nueva contraseña, la hasheamos
      if (_passwordController.text.isNotEmpty) {
        final passwordBytes = utf8.encode(_passwordController.text);
        final passwordHash = sha256.convert(passwordBytes);
        nuevoPasswordHash = passwordHash.toString();
      }

      final usuarioActualizado = Usuario(
        id: widget.usuario.id,
        nombreUsuario: widget.usuario.nombreUsuario,
        passwordHash: nuevoPasswordHash,
        rol: _rolSeleccionado,
      );

      await _usuarioDao.actualizar(usuarioActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario actualizado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${widget.usuario.nombreUsuario}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Usuario: ${widget.usuario.nombreUsuario}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText:
                      'Nueva Contraseña (dejar en blanco para no cambiar)',
                ),
                obscureText: true,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
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
              BotonPrincipal(
                texto: 'Guardar Cambios',
                onPressed: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
