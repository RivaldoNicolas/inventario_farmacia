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
          title: Text(item.producto.nombre),
          subtitle: Text(item.producto.laboratorio),
          trailing: Text(
            'Stock: ${item.stockTotal}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
