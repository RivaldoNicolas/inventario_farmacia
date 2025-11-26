/// La clase `Producto` representa el catálogo maestro de medicamentos.
/// Contiene la información general de un medicamento que no cambia con cada lote.
class Producto {
  final int? id;
  final String nombre;
  final String laboratorio;
  final String? codigo; // Código de barras o SKU. Es opcional pero muy útil.
  final String? descripcion;

  Producto({
    this.id,
    required this.nombre,
    required this.laboratorio,
    this.codigo,
    this.descripcion,
  });

  /// Convierte un objeto Producto a un Map para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'laboratorio': laboratorio,
      'codigo': codigo,
      'descripcion': descripcion,
    };
  }

  /// Crea un objeto Producto a partir de un Map de la base de datos.
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      laboratorio: map['laboratorio'],
      codigo: map['codigo'],
      descripcion: map['descripcion'],
    );
  }
}
