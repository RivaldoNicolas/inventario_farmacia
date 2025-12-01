/// Modelo para representar un movimiento de inventario
class Movimiento {
  final int? id;
  final int productoId;
  final String
  tipo; // 'Entrada', 'Salida por Venta', 'Baja por Vencimiento', 'Ajuste Manual'
  final int cantidad;
  final DateTime fecha;
  final String? motivo;
  // Motivo opcional para el movimiento (por ejemplo, razón de ajuste)
  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.motivo,
  });

  // Convierte el objeto Movimiento a un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productoId': productoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo,
    };
  }

  // Crea un objeto Movimiento a partir de un mapa de la base de datos.
  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'],
      productoId: map['productoId'],
      tipo: map['tipo'],
      cantidad: map['cantidad'],
      fecha: DateTime.parse(map['fecha']),
      motivo: map['motivo'],
    );
  }
}
