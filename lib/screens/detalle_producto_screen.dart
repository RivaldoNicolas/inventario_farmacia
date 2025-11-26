import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/producto.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  final _loteDao = LoteDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laboratorio: ${widget.producto.laboratorio}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.producto.codigo != null)
              Text(
                'Código: ${widget.producto.codigo}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 24),
            Text(
              'Lotes en Inventario',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            // Lista de lotes
            Expanded(
              child: FutureBuilder<List<Lote>>(
                future: _loteDao.obtenerLotesPorProducto(widget.producto.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay lotes para este producto.'),
                    );
                  }

                  final lotes = snapshot.data!;

                  return ListView.builder(
                    itemCount: lotes.length,
                    itemBuilder: (context, index) {
                      final lote = lotes[index];
                      return Card(
                        color: lote.fechaVencimiento.isBefore(DateTime.now())
                            ? Colors.red[100]
                            : null,
                        child: ListTile(
                          title: Text('Cantidad: ${lote.cantidad} unidades'),
                          subtitle: Text(
                            'Vence: ${lote.fechaVencimiento.day}/${lote.fechaVencimiento.month}/${lote.fechaVencimiento.year}',
                          ),
                          trailing:
                              lote.fechaVencimiento.isBefore(DateTime.now())
                              ? const Icon(Icons.warning, color: Colors.red)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
