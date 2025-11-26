import '../models/lote.dart';
import 'base_datos.dart';

class LoteDao {
  final dbHelper = DatabaseHelper.instance;

  /// Inserta un nuevo lote de un producto.
  Future<int> insertar(Lote lote) async {
    final db = await dbHelper.database;
    return await db.insert('lotes', lote.toMap());
  }

  /// Obtiene todos los lotes de un producto específico.
  Future<List<Lote>> obtenerLotesPorProducto(int productoId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lotes',
      where: 'productoId = ?',
      whereArgs: [productoId],
    );

    return List.generate(maps.length, (i) {
      return Lote.fromMap(maps[i]);
    });
  }

  /// Actualiza la información de un lote (por ejemplo, la cantidad).
  Future<int> actualizar(Lote lote) async {
    final db = await dbHelper.database;
    return await db.update(
      'lotes',
      lote.toMap(),
      where: 'id = ?',
      whereArgs: [lote.id],
    );
  }

  /// Elimina un lote específico.
  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;
    return await db.delete('lotes', where: 'id = ?', whereArgs: [id]);
  }
}
