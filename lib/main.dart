import 'dart:convert';
import 'dart:io' show Platform; // Para verificar la plataforma (Windows, etc.)
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importar sqflite_common_ffi
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import para inicializar el formato de fecha
import 'package:inventario_farmacia/screens/login_screen.dart';

void main() async {
  // Aseguramos la inicialización de Flutter antes de usar los DAOs
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(
    'es_ES',
    null,
  ); // Inicializa el formato para español

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

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Farmacia',
      debugShowCheckedModeBanner: false, // Oculta la cinta de "Debug"
      // --- TEMA MODERNO Y FUTURISTA ---
      theme: ThemeData(
        fontFamily: 'Poppins', // Fuente principal de la app
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Nuevo azul primario
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00C853), // Nuevo verde de acento
          background: const Color(0xFFF7F7F7),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: const Color(0xFF0B2545), // Color de texto principal
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E88E5), // Usamos el nuevo azul
          foregroundColor: Colors.white, // Texto e iconos blancos
          elevation: 2,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
      // --- CONFIGURACIÓN DE IDIOMA PARA LA APP ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (Opcional)
      ],
      home:
          const LoginScreen(), // Establecemos la pantalla de login como la inicial.
    );
  }
}
