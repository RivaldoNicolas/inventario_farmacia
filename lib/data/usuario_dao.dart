import '../models/usuario.dart';
import 'base_datos.dart';

class UsuarioDao {
  final dbHelper = DatabaseHelper.instance;

  /// Inserta un nuevo usuario.
  Future<int> insertar(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert('usuarios', usuario.toMap());
  }

  /// Busca un usuario por su nombre de usuario.
  /// Devuelve el usuario si lo encuentra, o null si no existe.
  Future<Usuario?> obtenerPorNombreUsuario(String nombreUsuario) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nombreUsuario = ?',
      whereArgs: [nombreUsuario],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Obtiene todos los usuarios de la base de datos.
  Future<List<Usuario>> obtenerTodos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      orderBy: 'nombreUsuario ASC',
    );

    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  /// Actualiza un usuario existente.
  Future<int> actualizar(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  /// Elimina un usuario por su ID.
  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}
