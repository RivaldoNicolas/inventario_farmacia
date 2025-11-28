import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/models/inventario_filtro.dart';
import 'package:inventario_farmacia/models/usuario.dart'; // Asegúrate que la ruta sea correcta
import 'package:inventario_farmacia/screens/agregar_medicamento_screen.dart';
import 'package:inventario_farmacia/screens/inventario_screen.dart';
import 'package:inventario_farmacia/screens/login_screen.dart';
import 'package:inventario_farmacia/screens/gestion_usuarios_screen.dart';
import 'package:inventario_farmacia/widgets/accion_rapida_card.dart';
import 'package:inventario_farmacia/widgets/alerta_dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LoteDao _loteDao = LoteDao();
  int _stockBajoCount = 0;
  int _proximosAVencerCount = 0;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    final stockBajo = await _loteDao.contarProductosConStockBajo();
    final proximosAVencer = await _loteDao.contarProductosProximosAVencer(90);
    if (mounted) {
      setState(() {
        _stockBajoCount = stockBajo;
        _proximosAVencerCount = proximosAVencer;
      });
    }
  }

  void _navegarAInventario([InventarioFiltro? filtro]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventarioScreen(filtroInicial: filtro),
      ),
    ).then((_) => _cargarAlertas());
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = widget.usuario.rol == 'administrador';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        automaticallyImplyLeading: false, // Oculta el botón de regreso
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Navega a la pantalla de login y elimina todas las rutas anteriores.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarAlertas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBienvenida(context),
              const SizedBox(height: 24),
              _buildSeccionAlertas(context),
              const SizedBox(height: 24),
              _buildSeccionAcciones(context, esAdmin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBienvenida(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Color.lerp(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              0.4,
            )!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido de vuelta!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.usuario.nombreUsuario,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            label: Text(
              widget.usuario.rol.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionAlertas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas Importantes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AlertaDashboardCard(
                titulo: 'Stock Bajo',
                contador: _stockBajoCount,
                icono: Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                onTap: () => _navegarAInventario(InventarioFiltro.stockBajo),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AlertaDashboardCard(
                titulo: 'Próximos a Vencer',
                contador: _proximosAVencerCount,
                icono: Icons.timer_off_outlined,
                color: Colors.red.shade700,
                onTap: () =>
                    _navegarAInventario(InventarioFiltro.proximosAVencer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionAcciones(BuildContext context, bool esAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones Rápidas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            AccionRapidaCard(
              titulo: 'Ver\nInventario',
              icono: Icons.inventory_2_outlined,
              onTap: () => _navegarAInventario(),
            ),
            AccionRapidaCard(
              titulo: 'Agregar\nMedicamento',
              icono: Icons.add_box_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AgregarMedicamentoScreen();
                  },
                ),
              ),
            ),
            if (esAdmin)
              AccionRapidaCard(
                titulo: 'Gestionar\nUsuarios',
                icono: Icons.people_alt_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GestionUsuariosScreen(adminId: widget.usuario.id!),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
