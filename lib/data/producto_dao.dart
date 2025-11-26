import '../models/producto.dart';
import 'base_datos.dart';

class ProductoDao {
  final dbHelper = DatabaseHelper.instance;

  /// Inserta un nuevo producto en el catálogo.
  Future<int> insertar(Producto producto) async {
    final db = await dbHelper.database;
    return await db.insert('productos', producto.toMap());
  }

  /// Obtiene todos los productos del catálogo.
  Future<List<Producto>> obtenerTodos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('productos');

    return List.generate(maps.length, (i) {
      return Producto.fromMap(maps[i]);
    });
  }

  /// Actualiza un producto existente.
  Future<int> actualizar(Producto producto) async {
    final db = await dbHelper.database;
    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  /// Elimina un producto del catálogo.
  /// Gracias a 'ON DELETE CASCADE' en la base de datos,
  /// todos los lotes asociados a este producto también se eliminarán.
  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}
