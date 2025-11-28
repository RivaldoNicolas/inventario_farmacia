import 'package:inventario_farmacia/models/lote.dart';
import 'package:sqflite/sqflite.dart';
import 'base_datos.dart';

class LoteDao {
  final dbHelper = DatabaseHelper.instance;

  /// Inserta un nuevo lote.
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
      orderBy: 'fechaVencimiento ASC',
    );

    return List.generate(maps.length, (i) => Lote.fromMap(maps[i]));
  }

  /// Actualiza un lote existente.
  Future<int> actualizar(Lote lote) async {
    final db = await dbHelper.database;
    return await db.update(
      'lotes',
      lote.toMap(),
      where: 'id = ?',
      whereArgs: [lote.id],
    );
  }

  /// Elimina un lote por su ID.
  Future<int> eliminar(int id) async {
    final db = await dbHelper.database;
    return await db.delete('lotes', where: 'id = ?', whereArgs: [id]);
  }

  /// --- MÉTODOS PARA EL DASHBOARD ---

  /// Cuenta la cantidad de productos distintos cuyo stock total está por debajo del mínimo.
  Future<int> contarProductosConStockBajo() async {
    final db = await dbHelper.database;
    // Esta consulta es más compleja:
    // 1. Calcula el stock total para cada producto sumando las cantidades de sus lotes.
    // 2. Compara ese total con el `stockMinimo` definido en la tabla de productos.
    // 3. Cuenta cuántos productos cumplen la condición de tener stock bajo.
    final result = await db.rawQuery('''
      SELECT COUNT(T1.id) as count
      FROM productos T1
      INNER JOIN (
        SELECT productoId, SUM(cantidad) as stockTotal
        FROM lotes
        GROUP BY productoId
      ) T2 ON T1.id = T2.productoId
      WHERE T1.stockMinimo IS NOT NULL AND T2.stockTotal <= T1.stockMinimo
    ''');

    if (result.isNotEmpty) {
      return Sqflite.firstIntValue(result) ?? 0;
    }
    return 0;
  }

  /// Cuenta la cantidad de productos distintos que tienen al menos un lote próximo a vencer.
  /// [dias] define el umbral de "próximo a vencer".
  Future<int> contarProductosProximosAVencer(int dias) async {
    final db = await dbHelper.database;
    final fechaLimite = DateTime.now().add(Duration(days: dias));

    // Esta consulta cuenta los productos únicos (DISTINCT) que tienen al menos
    // un lote cuya fecha de vencimiento es anterior a la fecha límite.
    final result = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT productoId) as count
      FROM lotes
      WHERE fechaVencimiento < ?
    ''',
      [fechaLimite.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return Sqflite.firstIntValue(result) ?? 0;
    }
    return 0;
  }
}
