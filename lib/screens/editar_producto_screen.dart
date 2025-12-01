import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/models/producto.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';

//Pantalla para editar un producto existente
class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

//Estados de la pantalla de edición de producto
class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _laboratorioController;
  late TextEditingController _codigoController;
  late TextEditingController _stockMinimoController;

  final _productoDao = ProductoDao();
  //Inicializa el estado
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

  //Guarda los cambios realizados en el producto
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

  //Construye la interfaz de edición de producto
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 16),
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
                texto: 'Guardar Cambios',
                onPressed: _guardarCambios,
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

  //Limpia los controladores al salir de la pantalla
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
