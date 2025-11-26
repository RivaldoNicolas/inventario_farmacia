/// Modelo para representar a un usuario de la aplicación.
class Usuario {
  final int? id;
  final String
  nombreUsuario; // Puede ser el correo o un nombre de usuario único.
  final String passwordHash; // NUNCA guardamos la contraseña en texto plano.
  final String rol; // 'administrador' o 'personal'

  Usuario({
    this.id,
    required this.nombreUsuario,
    required this.passwordHash,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'passwordHash': passwordHash,
      'rol': rol,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombreUsuario: map['nombreUsuario'],
      passwordHash: map['passwordHash'],
      rol: map['rol'],
    );
  }
}
