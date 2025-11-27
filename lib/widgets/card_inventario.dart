import 'package:flutter/material.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';

class CardInventario extends StatelessWidget {
  final ProductoInventario item;
  final VoidCallback onTap;

  const CardInventario({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.tieneLotesProximosAVencer)
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              if (item.tieneStockBajo)
                const Icon(Icons.inventory_2_outlined, color: Colors.red),
            ],
          ),
          title: Text(item.producto.nombre),
          subtitle: Text(item.producto.laboratorio),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (item.tieneStockBajo || item.tieneLotesProximosAVencer)
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Stock: ${item.stockTotal}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: (item.tieneStockBajo || item.tieneLotesProximosAVencer)
                    ? Colors.red.shade800
                    : Colors.green.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
