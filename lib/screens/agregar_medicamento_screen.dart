import 'package:flutter/material.dart';

class AgregarMedicamentoScreen extends StatelessWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Medicamento')),
      body: const Center(
        child: Text(
          'Aquí irá el formulario para agregar un nuevo medicamento.',
        ),
      ),
    );
  }
}
