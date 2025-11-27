import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';

import '../widgets/boton_principal.dart';

class AgregarLoteScreen extends StatefulWidget {
  final int productoId;

  const AgregarLoteScreen({super.key, required this.productoId});

  @override
  State<AgregarLoteScreen> createState() => _AgregarLoteScreenState();
}

class _AgregarLoteScreenState extends State<AgregarLoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();

  // Variable para guardar la fecha de vencimiento seleccionada
  DateTime? _fechaVencimiento;

  // Instancia de nuestro DAO
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nuevo Lote')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad del Lote',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
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
                controller: _precioCompraController,
                decoration: const InputDecoration(
                  labelText: 'Precio de Compra (Opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              BotonPrincipal(texto: 'Guardar Lote', onPressed: _guardarLote),
            ],
          ),
        ),
      ),
    );
  }
}
