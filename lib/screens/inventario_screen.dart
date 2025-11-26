import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/producto.dart';

// ViewModel para combinar la información del producto y su stock total.
class ProductoInventario {
  final Producto producto;
  final int stockTotal;

  ProductoInventario({required this.producto, required this.stockTotal});
}

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _productoDao = ProductoDao();
  final _loteDao = LoteDao();

  // Este método carga todo el inventario desde la base de datos.
  Future<List<ProductoInventario>> _cargarInventario() async {
    final productos = await _productoDao.obtenerTodos();
    final List<ProductoInventario> inventario = [];

    for (var producto in productos) {
      final lotes = await _loteDao.obtenerLotesPorProducto(producto.id!);
      // Suma las cantidades de todos los lotes para obtener el stock total.
      final stockTotal = lotes.fold<int>(0, (sum, lote) => sum + lote.cantidad);
      inventario.add(
        ProductoInventario(producto: producto, stockTotal: stockTotal),
      );
    }

    return inventario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Medicamentos')),
      // Usamos un FutureBuilder para manejar el estado de carga de los datos.
      body: FutureBuilder<List<ProductoInventario>>(
        future: _cargarInventario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay medicamentos en el inventario.'),
            );
          }

          final inventario = snapshot.data!;

          // Usamos un ListView.builder para mostrar la lista de forma eficiente.
          return ListView.builder(
            itemCount: inventario.length,
            itemBuilder: (context, index) {
              final item = inventario[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item.producto.nombre),
                  subtitle: Text(item.producto.laboratorio),
                  trailing: Text(
                    'Stock: ${item.stockTotal}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
