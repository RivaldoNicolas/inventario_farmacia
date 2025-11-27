/// La clase `Producto` representa el catálogo de medicamentos.
class Producto {
  final int? id;
  final String nombre;
  final String laboratorio;
  final String? codigo; //Codigo de Barra
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
