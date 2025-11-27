import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/movimiento_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/models/movimiento.dart';
import 'package:inventario_farmacia/screens/agregar_lote_screen.dart'; // Verificando que la ruta sea correcta
import 'package:inventario_farmacia/screens/editar_producto_screen.dart';
import 'package:inventario_farmacia/screens/historial_movimientos_screen.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final _loteDao = LoteDao();
  final _productoDao = ProductoDao();
  final _movimientoDao = MovimientoDao();
  late Producto _productoActual;
  late Future<List<Lote>> _lotesFuture;

  @override
  void initState() {
    super.initState();
    _productoActual = widget.producto;
    _cargarLotes();
  }

  void _cargarLotes() {
    setState(() {
      // Ordenamos por fecha de vencimiento (FEFO)
      _lotesFuture = _loteDao.obtenerLotesPorProducto(widget.producto.id!).then(
        (lotes) {
          lotes.sort(
            (a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento),
          );
          return lotes;
        },
      );
    });
  }

  void _navegarYRecargar() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgregarLoteScreen(productoId: widget.producto.id!),
      ),
    );

    // Si `resultado` es true, significa que se guardó un lote y debemos recargar.
    if (resultado == true) {
      _cargarLotes();
    }
  }

  void _navegarAEditarProducto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarProductoScreen(producto: _productoActual),
      ),
    );

    if (resultado == true) {
      // Si se guardaron cambios, recargamos la información del producto
      final productoActualizado = await _productoDao.obtenerPorId(
        _productoActual.id!,
      );
      setState(() => _productoActual = productoActualizado!);
      _cargarLotes(); // También recargamos los lotes por si acaso
    }
  }

  void _navegarAHistorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistorialMovimientosScreen(
          productoId: _productoActual.id!,
          productoNombre: _productoActual.nombre,
        ),
      ),
    );
  }

  void _mostrarDialogoSalida(Lote lote) {
    final cantidadController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Salida de Stock'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a descontar',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                final cantidad = int.tryParse(value);
                if (cantidad == null || cantidad <= 0) {
                  return 'Ingrese un número válido';
                }
                if (cantidad > lote.cantidad) {
                  return 'Stock insuficiente en este lote (${lote.cantidad})';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _registrarSalida(lote, int.parse(cantidadController.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _registrarSalida(Lote lote, int cantidadSalida) async {
    lote.cantidad -= cantidadSalida;

    if (lote.cantidad > 0) {
      await _loteDao.actualizar(lote);
    } else {
      // Si el stock del lote llega a 0, lo eliminamos.
      await _loteDao.eliminar(lote.id!);
    }

    // REGISTRAR MOVIMIENTO DE SALIDA
    final movimiento = Movimiento(
      productoId: _productoActual.id!,
      tipo: 'Salida por Venta/Uso',
      cantidad: cantidadSalida * -1, // En negativo para indicar salida
      fecha: DateTime.now(),
      motivo: 'Venta o uso regular',
    );
    await _movimientoDao.insertar(movimiento);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salida registrada con éxito.'),
        backgroundColor: Colors.green,
      ),
    );

    // Recargamos la lista de lotes para reflejar el cambio.
    _cargarLotes();
  }

  void _mostrarDialogoEliminarProducto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar este producto? Todos sus lotes asociados también serán eliminados. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _productoDao.eliminar(_productoActual.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado con éxito.'),
                  backgroundColor: Colors.green,
                ),
              );
              // Volvemos a la pantalla de inventario
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarLote(Lote lote) {
    final cantidadController = TextEditingController(
      text: lote.cantidad.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cantidad del Lote'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nueva cantidad'),
            validator: (v) =>
                (v == null ||
                    v.isEmpty ||
                    int.tryParse(v) == null ||
                    int.parse(v) < 0)
                ? 'Ingrese un número válido'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final cantidadAnterior = lote.cantidad;
                final nuevaCantidad = int.parse(cantidadController.text);

                // REGISTRAR MOVIMIENTO DE AJUSTE
                final movimiento = Movimiento(
                  productoId: _productoActual.id!,
                  tipo: 'Ajuste Manual',
                  cantidad: nuevaCantidad - cantidadAnterior, // La diferencia
                  fecha: DateTime.now(),
                  motivo: 'Corrección de inventario',
                );
                await _movimientoDao.insertar(movimiento);
                lote.cantidad = nuevaCantidad;
                await _loteDao.actualizar(lote);
                Navigator.pop(context);
                _cargarLotes(); // Recargar
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminarLote(Lote lote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: const Text('¿Está seguro de que desea eliminar este lote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _loteDao.eliminar(lote.id!);

              // REGISTRAR MOVIMIENTO DE BAJA
              final movimiento = Movimiento(
                productoId: _productoActual.id!,
                tipo: 'Baja de Lote',
                cantidad: lote.cantidad * -1, // En negativo
                fecha: DateTime.now(),
                motivo: 'Eliminación completa del lote ID: ${lote.id}',
              );
              await _movimientoDao.insertar(movimiento);
              Navigator.pop(context);
              _cargarLotes(); // Recargar
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_productoActual.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navegarAHistorial,
            tooltip: 'Ver Historial',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navegarAEditarProducto,
            tooltip: 'Editar Producto',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _mostrarDialogoEliminarProducto,
            tooltip: 'Eliminar Producto',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laboratorio: ${_productoActual.laboratorio}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_productoActual.codigo != null)
                  Text('Código: ${_productoActual.codigo}'),
                const SizedBox(height: 16),
                Text(
                  'Lotes en Inventario:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Lote>>(
              future: _lotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay lotes para este producto.'),
                  );
                }

                final lotes = snapshot.data!;
                return ListView.builder(
                  itemCount: lotes.length,
                  itemBuilder: (context, index) {
                    final lote = lotes[index];
                    final esProximoAVencer = lote.fechaVencimiento.isBefore(
                      DateTime.now().add(const Duration(days: 90)),
                    );
                    return Card(
                      color: esProximoAVencer ? Colors.orange.shade100 : null,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text('Stock: ${lote.cantidad} unidades'),
                        subtitle: Text(
                          'Vence: ${lote.fechaVencimiento.day}/${lote.fechaVencimiento.month}/${lote.fechaVencimiento.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _mostrarDialogoSalida(lote),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade300,
                              ),
                              child: const Text(
                                'Salida',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'editar')
                                  _mostrarDialogoEditarLote(lote);
                                if (value == 'eliminar')
                                  _mostrarDialogoEliminarLote(lote);
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarYRecargar,
        icon: const Icon(Icons.add),
        label: const Text('Añadir Lote'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
