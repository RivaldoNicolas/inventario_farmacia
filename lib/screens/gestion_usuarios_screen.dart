import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/crear_usuario_screen.dart';
import 'package:inventario_farmacia/screens/editar_usuario_screen.dart';

//Pantalla para la gestión de usuarios
class GestionUsuariosScreen extends StatefulWidget {
  final int adminId; // ID del admin actual para no mostrarlo en la lista

  const GestionUsuariosScreen({super.key, required this.adminId});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

//Estados de la pantalla de gestión de usuarios
class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final _usuarioDao = UsuarioDao();
  late Future<List<Usuario>> _usuariosFuture;
  //Inicializa el estado
  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  // Carga la lista de usuarios desde la base de datos
  void _cargarUsuarios() {
    setState(() {
      _usuariosFuture = _usuarioDao.obtenerTodos();
    });
  }

  // Navega a la pantalla de creación de usuario
  void _navegarACrearUsuario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearUsuarioScreen()),
    );
    // Recargar la lista por si se creó un nuevo usuario
    _cargarUsuarios();
  }

  // Navega a la pantalla de edición de usuario
  void _navegarAEditarUsuario(Usuario usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuarioScreen(usuario: usuario),
      ),
    );
    // Recargar la lista por si se editó el usuario
    _cargarUsuarios();
  }

  // Muestra un diálogo para confirmar la eliminación de un usuario
  void _mostrarDialogoEliminar(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Está seguro de que desea eliminar al usuario ${usuario.nombreUsuario}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _usuarioDao.eliminar(usuario.id!);
              Navigator.pop(context);
              _cargarUsuarios(); // Recargar la lista
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  //Construye la interfaz de la pantalla de gestión de usuarios
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
            return const Center(
              child: Text('No hay otros usuarios registrados.'),
            );
          }

          final usuarios = snapshot.data!;
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final esAdminActual = usuario.id == widget.adminId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    usuario.rol == 'administrador'
                        ? Icons.shield_rounded
                        : Icons.person_rounded,
                  ),
                  title: Text(usuario.nombreUsuario),
                  subtitle: Text('Rol: ${usuario.rol}'),
                  trailing: esAdminActual
                      ? const Chip(label: Text('Tú'))
                      : PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _navegarAEditarUsuario(usuario);
                            } else if (value == 'eliminar') {
                              _mostrarDialogoEliminar(usuario);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarACrearUsuario,
        icon: const Icon(Icons.add),
        label: const Text('Crear Usuario'),
      ),
    );
  }
}
