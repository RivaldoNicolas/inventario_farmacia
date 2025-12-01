import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/movimiento_dao.dart';
import 'package:inventario_farmacia/models/movimiento.dart';
import 'package:inventario_farmacia/models/lote.dart';

import '../widgets/boton_principal.dart';

//Pantalla para agregar un nuevo lote al inventario
class AgregarLoteScreen extends StatefulWidget {
  final int productoId;

  const AgregarLoteScreen({super.key, required this.productoId});

  @override
  State<AgregarLoteScreen> createState() => _AgregarLoteScreenState();
}

//Estados de la pantalla de agregar lote
class _AgregarLoteScreenState extends State<AgregarLoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();

  // Variable para guardar la fecha de vencimiento seleccionada
  DateTime? _fechaVencimiento;

  // Instancia de nuestro DAO
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

  // Método para guardar el nuevo lote
  void _guardarLote() async {
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

      // 1. Crear el objeto Lote
      final lote = Lote(
        productoId: widget.productoId,
        cantidad: int.parse(_cantidadController.text),
        fechaIngreso: DateTime.now(),
        fechaVencimiento: _fechaVencimiento!,
        precioCompra: _precioCompraController.text.isNotEmpty
            ? double.parse(_precioCompraController.text)
            : null,
      );

      // 2. Insertar el lote
      await _loteDao.insertar(lote);

      // 3. REGISTRAR MOVIMIENTO DE ENTRADA
      final movimiento = Movimiento(
        productoId: widget.productoId,
        tipo: 'Entrada de Lote',
        cantidad: lote.cantidad,
        fecha: DateTime.now(),
        motivo: 'Recepción de nuevo lote',
      );
      await _movimientoDao.insertar(movimiento);

      // 3. Mostrar confirmación y volver a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nuevo lote guardado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Devolvemos 'true' para indicar que se actualizó
    }
  }

  // Construye la interfaz de la pantalla de agregar lote
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nuevo Lote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomTextField(
                controller: _cantidadController,
                labelText: 'Cantidad del Lote',
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
              const SizedBox(height: 32),
              BotonPrincipal(texto: 'Guardar Lote', onPressed: _guardarLote),
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
