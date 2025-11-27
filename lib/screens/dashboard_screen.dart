import 'package:flutter/material.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/agregar_medicamento_screen.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';
import 'package:inventario_farmacia/screens/login_screen.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

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
              // Navega a la pantalla de login y elimina todas las rutas anteriores.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
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
            BotonPrincipal(
              texto: 'Ver Inventario',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventarioScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
      // Solo muestra el botón de agregar si el usuario es administrador.
      floatingActionButton: usuario.rol == 'administrador'
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgregarMedicamentoScreen(),
                ),
              ),
              tooltip: 'Agregar Medicamento',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
