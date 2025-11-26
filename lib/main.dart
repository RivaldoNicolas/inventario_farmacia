import 'dart:convert'; // Necesario para utf8
import 'package:crypto/crypto.dart'; // Necesario para el hash sha256
import 'dart:io' show Platform; // Para verificar la plataforma (Windows, etc.)
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/lote_dao.dart';
import 'package:inventario_farmacia/data/producto_dao.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/lote.dart';
import 'package:inventario_farmacia/models/producto.dart';
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

  // --- INICIO DE LA PRUEBA COMPLETA DE DAOs ---
  print("--- Iniciando prueba de la base de datos ---");

  // 1. Probar el DAO de Usuarios
  final usuarioDao = UsuarioDao();
  final passwordPlana = 'admin123';
  final bytes = utf8.encode(passwordPlana); // Convertir password a bytes
  final hash = sha256.convert(bytes); // Crear el hash

  final admin = Usuario(
    nombreUsuario: 'admin@farmacia.com',
    passwordHash: hash.toString(), // Guardar el hash como String
    rol: 'administrador',
  );
  await usuarioDao.insertar(admin);
  print("Usuario 'admin' insertado con hash: ${hash.toString()}");

  // 2. Probar el DAO de Productos
  final productoDao = ProductoDao();
  final producto = Producto(
    nombre: 'Amoxicilina 500mg',
    laboratorio: 'PharmaCorp',
    codigo: '770123456789',
  );
  // El método 'insertar' devuelve el ID del nuevo producto, lo guardamos.
  final productoId = await productoDao.insertar(producto);
  print("Producto '${producto.nombre}' insertado con ID: $productoId");

  // 3. Probar el DAO de Lotes
  final loteDao = LoteDao();
  final lote = Lote(
    productoId:
        productoId, // Usamos el ID que obtuvimos al insertar el producto
    cantidad: 100,
    fechaIngreso: DateTime.now(),
    fechaVencimiento: DateTime(2027, 5, 20),
    precioCompra: 15.50,
  );
  await loteDao.insertar(lote);
  print(
    "Lote para el producto ID $productoId insertado con cantidad: ${lote.cantidad}",
  );

  // 4. Verificación final: Leer los datos
  print("\n--- VERIFICACIÓN ---");
  final usuarioEncontrado = await usuarioDao.obtenerPorNombreUsuario(
    'admin@farmacia.com',
  );
  print(
    "Usuario encontrado: ${usuarioEncontrado?.nombreUsuario}, Rol: ${usuarioEncontrado?.rol}",
  );

  final productosEncontrados = await productoDao.obtenerTodos();
  print("Total de productos en catálogo: ${productosEncontrados.length}");

  final lotesEncontrados = await loteDao.obtenerLotesPorProducto(productoId);
  print(
    "Lotes encontrados para el producto ID $productoId: ${lotesEncontrados.length}",
  );
  if (lotesEncontrados.isNotEmpty) {
    print("  -> Cantidad del primer lote: ${lotesEncontrados.first.cantidad}");
  }

  print("--- Fin de la prueba ---");
  // --- FIN DE LA PRUEBA ---

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
