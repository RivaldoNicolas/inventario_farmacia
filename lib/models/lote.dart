/// Modelo para representar un lote específico de un producto en inventario.
class Lote {
  final int? id;
  final int
  productoId; // Clave foránea que lo conecta con la tabla 'productos'.
  int cantidad; // La cantidad de este lote específico. Es mutable.
  final DateTime fechaIngreso;
  final DateTime fechaVencimiento;
  final double? precioCompra;
  // Constructor de la clase.
  Lote({
    this.id,
    required this.productoId,
    required this.cantidad,
    required this.fechaIngreso,
    required this.fechaVencimiento,
    this.precioCompra,
  });

  // Convierte el objeto Lote a un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'cantidad': cantidad,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'precioCompra': precioCompra,
    };
  }

  // Crea un objeto Lote a partir de un mapa de la base de datos.
  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'],
      productoId: map['productoId'],
      cantidad: map['cantidad'],
      fechaIngreso: DateTime.parse(map['fechaIngreso']),
      fechaVencimiento: DateTime.parse(map['fechaVencimiento']),
      precioCompra: map['precioCompra'],
    );
  }
}
