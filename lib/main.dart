import 'dart:io' show Platform; // Para verificar la plataforma (Windows, etc.)
import 'package:flutter/material.dart';
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
