import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/producto.dart';

class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _nombreController = TextEditingController();
  final _laboratorioController = TextEditingController();
  final _codigoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();

  // Variable para guardar la fecha de vencimiento seleccionada
  DateTime? _fechaVencimiento;

  // Instancias de nuestros DAOs
  final _productoDao = ProductoDao();
  final _loteDao = LoteDao();

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

      // 1. Crear el objeto Producto (del catálogo)
      final producto = Producto(
        nombre: _nombreController.text,
        laboratorio: _laboratorioController.text,
        codigo: _codigoController.text.isNotEmpty
            ? _codigoController.text
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

      // 5. Mostrar confirmación y volver a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicamento guardado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nuevo Medicamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Medicamento',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _laboratorioController,
                decoration: const InputDecoration(labelText: 'Laboratorio'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad Inicial (Stock)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              // --- Selector de Fecha ---
              ListTile(
                title: Text(
                  _fechaVencimiento == null
                      ? 'Seleccionar Fecha de Vencimiento'
                      : 'Vence: ${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _seleccionarFecha(context),
              ),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras (Opcional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioCompraController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Compra (Opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardarMedicamento,
                child: const Text('Guardar Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
