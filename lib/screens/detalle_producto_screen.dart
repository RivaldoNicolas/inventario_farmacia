import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/screens/agregar_lote_screen.dart'; // Verificando que la ruta sea correcta

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final _loteDao = LoteDao();
  late Future<List<Lote>> _lotesFuture;

  @override
  void initState() {
    super.initState();
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salida registrada con éxito.'),
        backgroundColor: Colors.green,
      ),
    );

    // Recargamos la lista de lotes para reflejar el cambio.
    _cargarLotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laboratorio: ${widget.producto.laboratorio}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.producto.codigo != null)
                  Text('Código: ${widget.producto.codigo}'),
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
                        trailing: ElevatedButton(
                          onPressed: () => _mostrarDialogoSalida(lote),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade300,
                          ),
                          child: const Text(
                            'Salida',
                            style: TextStyle(color: Colors.white),
                          ),
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
