import 'package:inventario_farmacia/models/movimiento.dart';
import 'base_datos.dart';

/// Data Access Object (DAO) para manejar las operaciones de la tabla de movimientos.
class MovimientoDao {
  final dbHelper = DatabaseHelper.instance;

  /// Inserta un nuevo movimiento.
  Future<int> insertar(Movimiento movimiento) async {
    final db = await dbHelper.database;
    return await db.insert('movimientos', movimiento.toMap());
  }

  /// Obtiene todos los movimientos de un producto específico, ordenados por fecha.
  Future<List<Movimiento>> obtenerPorProducto(int productoId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movimientos',
      where: 'productoId = ?',
      whereArgs: [productoId],
      orderBy: 'fecha DESC', // Los más recientes primero
    );

    return List.generate(maps.length, (i) => Movimiento.fromMap(maps[i]));
  }
}
