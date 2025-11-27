import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _laboratorioController;
  late TextEditingController _codigoController;
  late TextEditingController _stockMinimoController;

  final _productoDao = ProductoDao();

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos del producto existente
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _laboratorioController = TextEditingController(
      text: widget.producto.laboratorio,
    );
    _codigoController = TextEditingController(text: widget.producto.codigo);
    _stockMinimoController = TextEditingController(
      text: widget.producto.stockMinimo?.toString(),
    );
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      // Creamos un nuevo objeto Producto con los datos actualizados
      final productoActualizado = Producto(
        id: widget.producto.id, // Mantenemos el mismo ID
        nombre: _nombreController.text,
        laboratorio: _laboratorioController.text,
        codigo: _codigoController.text,
        stockMinimo: _stockMinimoController.text.isNotEmpty
            ? int.parse(_stockMinimoController.text)
            : null,
      );

      await _productoDao.actualizar(productoActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      // Devolvemos 'true' para indicar que la pantalla anterior debe recargarse
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
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
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras (Opcional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockMinimoController,
                decoration: const InputDecoration(
                  labelText: 'Stock Mínimo (Opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              BotonPrincipal(
                texto: 'Guardar Cambios',
                onPressed: _guardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiamos los controladores al salir de la pantalla
    _nombreController.dispose();
    _laboratorioController.dispose();
    _codigoController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }
}
