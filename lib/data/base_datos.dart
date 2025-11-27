import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// `DatabaseHelper` es una clase que maneja toda la lógica de conexión
/// y creación de la base de datos. Usamos el patrón Singleton para asegurarnos
/// de que solo exista una instancia de esta clase en toda la app, evitando
/// conflictos y múltiples conexiones a la base de datos.
class DatabaseHelper {
  // Hacemos la clase un Singleton.
  DatabaseHelper._privateConstructor(); // Constructor privado.
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor(); // Única instancia.

  // Esta variable guardará la referencia a la base de datos una vez que esté abierta.
  static Database? _database;

  // Getter para la base de datos. Si ya está inicializada, la devuelve.
  // Si no, la inicializa y la devuelve.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Método que inicializa la base de datos.
  Future<Database> _initDB() async {
    // Obtenemos la ruta donde se guardará el archivo de la base de datos.
    String path = join(await getDatabasesPath(), 'farmacia_inventario_v2.db');

    // Abrimos la base de datos. Si no existe, `_createDB` se ejecutará.
    return await openDatabase(
      path,
      version: 3, // ¡IMPORTANTE! Incrementamos la versión de la BD a 3.
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Añadimos el manejador de actualizaciones.
    );
  }

  // Método que se ejecuta cuando la versión de la BD cambia.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración de v1 a v2
      await db.execute('ALTER TABLE productos ADD COLUMN stockMinimo INTEGER');
    }
    if (oldVersion < 3) {
      // Migración de v2 a v3
      await db.execute('''
        CREATE TABLE movimientos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productoId INTEGER NOT NULL,
          tipo TEXT NOT NULL,
          cantidad INTEGER NOT NULL,
          fecha TEXT NOT NULL,
          motivo TEXT
        )
      ''');
    }
  }

  // Método que se ejecuta solo la primera vez que se crea la base de datos.
  // Aquí definimos la estructura de nuestras tablas.
  Future<void> _createDB(Database db, int version) async {
    // Tabla para los usuarios de la aplicación
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreUsuario TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        rol TEXT NOT NULL
      )
    ''');

    // Tabla para el catálogo maestro de productos/medicamentos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        laboratorio TEXT NOT NULL,
        codigo TEXT,
        descripcion TEXT,
        stockMinimo INTEGER
      )
    ''');

    // Tabla para los lotes de inventario, con su stock y vencimiento
    await db.execute('''
      CREATE TABLE lotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productoId INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        fechaIngreso TEXT NOT NULL,
        fechaVencimiento TEXT NOT NULL,
        precioCompra REAL,
        FOREIGN KEY (productoId) REFERENCES productos (id) ON DELETE CASCADE
      )
    ''');

    // Tabla para registrar todos los movimientos de inventario
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productoId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        motivo TEXT
      )
    ''');
  }
}
