import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/screens/agregar_medicamento_screen.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';
import 'package:inventario_farmacia/screens/login_screen.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _productoDao = ProductoDao();
  final _loteDao = LoteDao();

  int _productosConStockBajo = 0;
  int _lotesProximosAVencer = 0;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    final productos = await _productoDao.obtenerTodos();
    int stockBajoCount = 0;
    int vencimientoCount = 0;

    final fechaLimite = DateTime.now().add(const Duration(days: 90));

    for (var producto in productos) {
      final lotes = await _loteDao.obtenerLotesPorProducto(producto.id!);
      final stockTotal = lotes.fold<int>(0, (sum, lote) => sum + lote.cantidad);

      // Contar stock bajo
      if (producto.stockMinimo != null && stockTotal <= producto.stockMinimo!) {
        stockBajoCount++;
      }

      // Contar lotes próximos a vencer
      vencimientoCount += lotes
          .where((lote) => lote.fechaVencimiento.isBefore(fechaLimite))
          .length;
    }

    setState(() {
      _productosConStockBajo = stockBajoCount;
      _lotesProximosAVencer = vencimientoCount;
    });
  }

  void _navegarAInventarioYRecargar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventarioScreen()),
    );
    // Cuando volvemos del inventario, recargamos las alertas por si algo cambió.
    _cargarAlertas();
  }

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
              'Bienvenido, ${widget.usuario.nombreUsuario}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Rol: ${widget.usuario.rol}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            // --- Sección de Alertas ---
            const Text(
              'Resumen de Alertas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAlertCard(
                    context,
                    'Stock Bajo',
                    _productosConStockBajo,
                    Icons.inventory_2_outlined,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAlertCard(
                    context,
                    'Próximos a Vencer',
                    _lotesProximosAVencer,
                    Icons.warning_amber_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botón para ver el inventario
            BotonPrincipal(
              texto: 'Ver Inventario',
              onPressed: _navegarAInventarioYRecargar,
            ),
          ],
        ),
      ),
      // Solo muestra el botón de agregar si el usuario es administrador.
      floatingActionButton: widget.usuario.rol == 'administrador'
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

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
