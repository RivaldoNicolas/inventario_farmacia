import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/models/inventario_filtro.dart';
import 'package:inventario_farmacia/screens/detalle_producto_screen.dart'; // Verificando que la ruta sea correcta
import 'package:inventario_farmacia/widgets/card_inventario.dart';

// ViewModel para combinar la información del producto y su stock total.
class ProductoInventario {
  final Producto producto;
  final int stockTotal;
  final bool tieneStockBajo;
  final bool tieneLotesProximosAVencer;

  ProductoInventario({
    required this.producto,
    required this.stockTotal,
    this.tieneStockBajo = false,
    this.tieneLotesProximosAVencer = false,
  });
}

class InventarioScreen extends StatefulWidget {
  final InventarioFiltro? filtroInicial;

  const InventarioScreen({super.key, this.filtroInicial});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final _productoDao = ProductoDao();
  final _loteDao = LoteDao();

  // Controlador para la barra de búsqueda
  final _searchController = TextEditingController();
  // Lista que contendrá todos los items del inventario
  List<ProductoInventario> _inventarioCompleto = [];
  // Lista que mostrará los items filtrados por la búsqueda
  List<ProductoInventario> _inventarioFiltrado = [];

  // Este método carga todo el inventario desde la base de datos.
  Future<void> _cargarInventario() async {
    final productos = await _productoDao.obtenerTodos();
    final List<ProductoInventario> inventarioCargado = [];

    for (var producto in productos) {
      final lotes = await _loteDao.obtenerLotesPorProducto(producto.id!);
      // Suma las cantidades de todos los lotes para obtener el stock total.
      final stockTotal = lotes.fold<int>(0, (sum, lote) => sum + lote.cantidad);

      // --- Lógica de Alertas ---
      // 1. Alerta de Stock Bajo
      final bool stockBajo =
          producto.stockMinimo != null && stockTotal <= producto.stockMinimo!;

      // 2. Alerta de Vencimiento Próximo (ej. 90 días)
      final fechaLimite = DateTime.now().add(const Duration(days: 90));
      final bool vencimientoProximo = lotes.any(
        (lote) => lote.fechaVencimiento.isBefore(fechaLimite),
      );

      inventarioCargado.add(
        ProductoInventario(
          producto: producto,
          stockTotal: stockTotal,
          tieneStockBajo: stockBajo,
          tieneLotesProximosAVencer: vencimientoProximo,
        ),
      );
    }

    List<ProductoInventario> inventarioFiltradoInicial = inventarioCargado;
    // Aplicamos el filtro inicial si viene del dashboard
    if (widget.filtroInicial != null) {
      if (widget.filtroInicial == InventarioFiltro.stockBajo) {
        inventarioFiltradoInicial = inventarioCargado
            .where((p) => p.tieneStockBajo)
            .toList();
      } else if (widget.filtroInicial == InventarioFiltro.proximosAVencer) {
        inventarioFiltradoInicial = inventarioCargado
            .where((p) => p.tieneLotesProximosAVencer)
            .toList();
      }
    }

    setState(() {
      _inventarioCompleto = inventarioCargado;
      // La lista que se muestra inicialmente ya está filtrada si es necesario
      _inventarioFiltrado = inventarioFiltradoInicial;
    });
  }

  // Método para filtrar la lista basado en el texto de búsqueda
  void _filtrarInventario(String query) {
    final listaFiltrada = _inventarioCompleto.where((item) {
      final nombre = item.producto.nombre.toLowerCase();
      final laboratorio = item.producto.laboratorio.toLowerCase();
      final codigo = item.producto.codigo?.toLowerCase() ?? '';
      final busqueda = query.toLowerCase();
      return nombre.contains(busqueda) ||
          laboratorio.contains(busqueda) ||
          codigo.contains(busqueda);
    }).toList();

    setState(() {
      _inventarioFiltrado = listaFiltrada;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarInventario();
    // Añadimos un listener al controlador de búsqueda para filtrar en tiempo real
    _searchController.addListener(() {
      _filtrarInventario(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filtroInicial == null
              ? 'Inventario General'
              : widget.filtroInicial == InventarioFiltro.stockBajo
              ? 'Productos con Stock Bajo'
              : 'Lotes Próximos a Vencer',
        ),
      ),
      body: Column(
        children: [
          // --- Barra de Búsqueda ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, laboratorio o código',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // --- Lista de Medicamentos ---
          Expanded(
            child: _inventarioFiltrado.isEmpty
                ? Center(
                    child: Text(
                      widget.filtroInicial == null
                          ? 'No hay productos en el inventario.'
                          : 'No se encontraron productos con esta alerta.',
                    ),
                  )
                : ListView.builder(
                    itemCount: _inventarioFiltrado.length,
                    itemBuilder: (context, index) {
                      final item = _inventarioFiltrado[index];
                      return CardInventario(
                        item: item,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleProductoScreen(
                                producto: item.producto,
                              ),
                            ),
                          );
                          // Recargar el inventario al volver de los detalles
                          _cargarInventario();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
