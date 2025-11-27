import 'dart:convert';
import 'dart:io' show Platform; // Para verificar la plataforma (Windows, etc.)
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importar sqflite_common_ffi
import 'package:inventario_farmacia/screens/login_screen.dart';

void main() async {
  // Aseguramos la inicialización de Flutter antes de usar los DAOs
  WidgetsFlutterBinding.ensureInitialized();

  // SOLUCIÓN DEFINITIVA: Inicializar sqflite para plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // --- PROCEDIMIENTO DE EMERGENCIA PARA RESETEAR CONTRASEÑA DE ADMIN ---
  // Si el admin olvida su contraseña, cambia esta variable a 'true' y ejecuta la app una vez.
  const bool forzarReseteoAdmin = false;

  // --- LÓGICA PARA CREAR EL USUARIO ADMIN ---
  // Esta lógica crea el usuario la primera vez que la app se ejecuta en un dispositivo.
  final usuarioDao = UsuarioDao();
  final adminExiste = await usuarioDao.obtenerPorNombreUsuario(
    'admin@farmacia.com',
  );

  if (adminExiste == null || forzarReseteoAdmin) {
    // Si el admin no existe, lo creamos.
    final passwordBytes = utf8.encode('admin123');
    final passwordHash = sha256.convert(passwordBytes);

    final nuevoAdmin = Usuario(
      nombreUsuario: 'admin@farmacia.com',
      passwordHash: passwordHash.toString(),
      rol: 'administrador',
    );

    if (adminExiste == null) {
      await usuarioDao.insertar(nuevoAdmin);
      print('>>> Usuario administrador creado por primera vez.');
    } else {
      // Si el admin ya existe pero forzamos el reseteo, lo actualizamos.
      final usuarioParaActualizar = Usuario(
        id: adminExiste.id, // Usamos el ID existente
        nombreUsuario: nuevoAdmin.nombreUsuario,
        passwordHash: nuevoAdmin.passwordHash,
        rol: nuevoAdmin.rol,
      );
      await usuarioDao.actualizar(usuarioParaActualizar);
      print(
        '>>> CONTRASEÑA DE ADMINISTRADOR RESETEADA A "admin123" POR EMERGENCIA.',
      );
    }
  }

  runApp(const MyApp()); // El punto de entrada de la aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Farmacia',
      debugShowCheckedModeBanner: false, // Oculta la cinta de "Debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home:
          const LoginScreen(), // Establecemos la pantalla de login como la inicial.
    );
  }
}
