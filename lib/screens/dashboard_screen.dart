import 'package:flutter/material.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/agregar_medicamento_screen.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Usuario usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Lógica para cerrar sesión (a implementar)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${usuario.nombreUsuario}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Rol: ${usuario.rol}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            // Botón para ver el inventario
            ElevatedButton.icon(
              icon: const Icon(Icons.inventory),
              label: const Text('Ver Inventario'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventarioScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AgregarMedicamentoScreen(),
          ),
        ),
        tooltip: 'Agregar Medicamento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
