import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/crear_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _usuarioDao = UsuarioDao();
  late Future<List<Usuario>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  void _cargarUsuarios() {
    setState(() {
      _usuariosFuture = _usuarioDao.obtenerTodos();
    });
  }

  Future<void> _eliminarUsuario(int id) async {
    await _usuarioDao.eliminar(id);
    _cargarUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario eliminado correctamente.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: FutureBuilder<List<Usuario>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final usuarios = snapshot.data!;
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                leading: Icon(
                  usuario.rol == 'administrador'
                      ? Icons.shield_outlined
                      : Icons.person_outline,
                ),
                title: Text(usuario.nombreUsuario),
                subtitle: Text(usuario.rol),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _eliminarUsuario(usuario.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrearUsuarioScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
