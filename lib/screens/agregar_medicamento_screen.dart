import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/movimiento_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/movimiento.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

//Pantalla para agregar un nuevo medicamento al inventario
class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

//Estados de la pantalla de agregar medicamento
class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _nombreController = TextEditingController();
  final _laboratorioController = TextEditingController();
  final _codigoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  // Variable para guardar la fecha de vencimiento seleccionada
  DateTime? _fechaVencimiento;

  // Instancias de nuestros DAOs
  final _productoDao = ProductoDao();
  final _loteDao = LoteDao();
  final _movimientoDao = MovimientoDao();

  // Método para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fechaVencimiento) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  // Método para guardar el nuevo producto y su lote
  void _guardarMedicamento() async {
    // Validamos el formulario
    if (_formKey.currentState!.validate()) {
      if (_fechaVencimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, seleccione una fecha de vencimiento.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        // 1. Crear el objeto Producto (del catálogo)
        final producto = Producto(
          nombre: _nombreController.text,
          laboratorio: _laboratorioController.text,
          codigo: _codigoController.text.isNotEmpty
              ? _codigoController.text
              : null,
          stockMinimo: _stockMinimoController.text.isNotEmpty
              ? int.parse(_stockMinimoController.text)
              : null,
        );

        // 2. Insertar el producto y obtener su ID
        final productoId = await _productoDao.insertar(producto);

        // 3. Crear el objeto Lote (el stock inicial)
        final lote = Lote(
          productoId: productoId,
          cantidad: int.parse(_cantidadController.text),
          fechaIngreso: DateTime.now(),
          fechaVencimiento: _fechaVencimiento!,
          precioCompra: _precioCompraController.text.isNotEmpty
              ? double.parse(_precioCompraController.text)
              : null,
        );

        // 4. Insertar el lote
        await _loteDao.insertar(lote);

        // 5. REGISTRAR MOVIMIENTO DE ENTRADA
        final movimiento = Movimiento(
          productoId: productoId,
          tipo: 'Entrada Inicial',
          cantidad: lote.cantidad,
          fecha: DateTime.now(),
          motivo: 'Creación de producto',
        );
        await _movimientoDao.insertar(movimiento);

        // 6. Mostrar confirmación y volver a la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento guardado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        // Si algo falla durante el guardado, mostramos el error.
        print('Error al guardar medicamento: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget reutilizable para los títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Construye la sección de bienvenida del usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nuevo Medicamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Sección de Información Principal ---
              _buildSectionTitle('Información Principal'),
              _buildCustomTextField(
                controller: _nombreController,
                labelText: 'Nombre del Medicamento',
                icon: Icons.medication_outlined,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                controller: _laboratorioController,
                labelText: 'Laboratorio',
                icon: Icons.business_outlined,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),

              // --- Sección de Lote Inicial ---
              _buildSectionTitle('Lote Inicial'),
              _buildCustomTextField(
                controller: _cantidadController,
                labelText: 'Cantidad Inicial (Stock)',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildCustomTextField(
                controller: _precioCompraController,
                labelText: 'Precio de Compra (Opcional)',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // --- Sección de Datos Adicionales ---
              _buildSectionTitle('Datos Adicionales'),
              _buildCustomTextField(
                controller: _codigoController,
                labelText: 'Código de Barras (Opcional)',
                icon: Icons.qr_code_scanner_outlined,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                controller: _stockMinimoController,
                labelText: 'Stock Mínimo (Opcional)',
                icon: Icons.warning_amber_rounded,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 32),
              BotonPrincipal(
                texto: 'Guardar Medicamento',
                onPressed: _guardarMedicamento,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto con el nuevo diseño
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // Widget para el selector de fecha con el nuevo diseño
  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _seleccionarFecha(context),
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Vencimiento',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        child: Text(
          _fechaVencimiento == null
              ? 'No seleccionada'
              : '${_fechaVencimiento!.day.toString().padLeft(2, '0')}/${_fechaVencimiento!.month.toString().padLeft(2, '0')}/${_fechaVencimiento!.year}',
          style: TextStyle(
            color: _fechaVencimiento == null
                ? Colors.grey.shade600
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
