class Movimiento {
  final int? id;
  final int productoId;
  final String
  tipo; // 'Entrada', 'Salida por Venta', 'Baja por Vencimiento', 'Ajuste Manual'
  final int cantidad;
  final DateTime fecha;
  final String? motivo;

  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.motivo,
  });

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
