import 'package:flutter/material.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';

// Tarjeta personalizada para mostrar cada ítem del inventario
class CardInventario extends StatelessWidget {
  final ProductoInventario item;
  final VoidCallback onTap;

  const CardInventario({super.key, required this.item, required this.onTap});
  // Construye la tarjeta del inventario
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          // Asegura que todos los hijos tengan la misma altura
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Estira los hijos verticalmente
            children: [
              // --- Iconos de Alerta a la Izquierda ---
              SizedBox(
                width: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.tieneLotesProximosAVencer)
                      Icon(
                        Icons.timer_off_outlined,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    if (item.tieneLotesProximosAVencer && item.tieneStockBajo)
                      const SizedBox(width: 4),
                    if (item.tieneStockBajo)
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                  ],
                ),
              ),
              // --- Nombre y Laboratorio ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centra verticalmente
                    children: [
                      Text(
                        item.producto.nombre,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.producto.laboratorio,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              // --- Indicador de Stock a la Derecha ---
              _StockBadge(
                stockTotal: item.stockTotal,
                tieneStockBajo: item.tieneStockBajo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Indicador visual del stock total del producto
class _StockBadge extends StatelessWidget {
  final int stockTotal;
  final bool tieneStockBajo;

  const _StockBadge({required this.stockTotal, required this.tieneStockBajo});
  // Construye el indicador de stock
  @override
  Widget build(BuildContext context) {
    final Color color;
    if (stockTotal <= 0) {
      color = Colors.red.shade700;
    } else if (tieneStockBajo) {
      color = Colors.orange.shade700;
    } else {
      color = Colors.green.shade700;
    }

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
      ),
      child: Center(
        child: Text(
          'Stock\n${stockTotal.toString()}',
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
