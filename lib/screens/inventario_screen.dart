import 'package:flutter/material.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Medicamentos')),
      body: const Center(
        child: Text('Aquí se listarán todos los medicamentos.'),
      ),
    );
  }
}
