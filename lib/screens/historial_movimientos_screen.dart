import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/movimiento_dao.dart';
import 'package:inventario_farmacia/models/movimiento.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

//Pantalla para mostrar el historial de movimientos de un producto
class HistorialMovimientosScreen extends StatefulWidget {
  final int productoId;
  final String productoNombre;

  const HistorialMovimientosScreen({
    super.key,
    required this.productoId,
    required this.productoNombre,
  });

  @override
  State<HistorialMovimientosScreen> createState() =>
      _HistorialMovimientosScreenState();
}

//Estados de la pantalla de historial de movimientos
class _HistorialMovimientosScreenState
    extends State<HistorialMovimientosScreen> {
  final _movimientoDao = MovimientoDao();
  late Future<List<Movimiento>> _movimientosFuture;

  @override
  void initState() {
    super.initState();
    _movimientosFuture = _movimientoDao.obtenerPorProducto(widget.productoId);
  }

  //Construye la interfaz de historial de movimientos
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de ${widget.productoNombre}')),
      body: FutureBuilder<List<Movimiento>>(
        future: _movimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay movimientos registrados para este producto.'),
            );
          }

          final movimientos = snapshot.data!;
          return ListView.builder(
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = movimientos[index];
              final esEntrada = movimiento.cantidad >= 0;
              final icono = esEntrada
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded;
              final color = esEntrada ? Colors.green : Colors.red;
              final cantidadFormateada =
                  '${esEntrada ? '+' : ''}${movimiento.cantidad}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: Icon(icono, color: color),
                  title: Text(
                    movimiento.tipo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(movimiento.fecha)}\n${movimiento.motivo ?? ''}',
                  ),
                  trailing: Text(
                    cantidadFormateada,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
