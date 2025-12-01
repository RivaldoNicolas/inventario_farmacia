import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:inventario_farmacia/data/usuario_dao.dart';
import 'package:inventario_farmacia/models/usuario.dart';
import 'package:inventario_farmacia/widgets/boton_principal.dart';
import 'package:inventario_farmacia/screens/dashboard_screen.dart';

// Convertimos LoginScreen a un StatefulWidget para manejar el estado del formulario.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Estado del LoginScreen
class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Clave para identificar y validar nuestro formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para obtener el texto de los campos del formulario.
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable para manejar la visibilidad de la contraseña.
  bool _obscurePassword = true;

  // Instancia de nuestro DAO para interactuar con la base de datos.
  final _usuarioDao = UsuarioDao();

  // Controlador de animación para la entrada del formulario
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;

  // Método que se ejecuta al presionar el botón de "Ingresar".
  void _login() async {
    // Primero, validamos que los campos del formulario no estén vacíos.
    if (_formKey.currentState!.validate()) {
      final nombreUsuario = _usuarioController.text;
      final password = _passwordController.text;

      // Buscamos al usuario en la base de datos.
      final Usuario? usuario = await _usuarioDao.obtenerPorNombreUsuario(
        nombreUsuario,
      );

      if (usuario != null) {
        // Si el usuario existe, hasheamos la contraseña ingresada para compararla.
        final bytes = utf8.encode(password);
        final hash = sha256.convert(bytes);

        if (hash.toString() == usuario.passwordHash) {
          // ¡Contraseña correcta! Navegamos al Dashboard.
          // Usamos pushReplacement para que el usuario no pueda volver atrás a la pantalla de login.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(usuario: usuario),
            ),
          );
        } else {
          // Contraseña incorrecta.
          _mostrarError('La contraseña es incorrecta.');
        }
      } else {
        // El usuario no existe.
        _mostrarError('El usuario no se encuentra registrado.');
      }
    }
  }

  // Método para mostrar un mensaje de error en un SnackBar.
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  // Inicializa el estado y configura la animación
  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de animación aquí.
    _animationController = AnimationController(
      vsync: this, // Necesario para la animación.
      duration: const Duration(milliseconds: 1200), // Duración de la animación.
    );

    // Creamos una animación de rotación para el icono
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    // Iniciamos la animación para que el formulario aparezca.
    _animationController.forward();
  }

  // Liberamos los recursos del controlador de animación
  @override
  void dispose() {
    // Liberamos los recursos de los controladores para evitar fugas de memoria.
    _animationController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Construye la interfaz del LoginScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header azul con icono y título
              Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                decoration: BoxDecoration(
                  // Gradiente para un look más moderno
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Color.lerp(
                        Theme.of(context).colorScheme.primary,
                        Colors.black,
                        0.2,
                      )!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ), // Bordes redondeados en la parte inferior
                ), // Fondo con color Teal del tema
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    // Icono de medicamento
                    RotationTransition(
                      turns: _iconAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.medication,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Control de Inventario\nFarmacia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accede para gestionar medicamentos de forma segura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulario de login con animación de entrada
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey, // Usamos la clave del formulario
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Campo de Correo/Usuario
                          TextFormField(
                            controller: _usuarioController,
                            decoration: InputDecoration(
                              hintText: 'Correo institucional / Usuario',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.grey.shade600,
                              ),
                              filled:
                                  true, // Fondo relleno para un look más moderno
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.surface, // Color de fondo del campo
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide.none, // Sin borde visible
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ), // Borde al enfocar
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, ingrese su usuario'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Campo de Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade600,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, ingrese su contraseña'
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // Botón Iniciar Sesión
                          BotonPrincipal(
                            texto: 'Iniciar Sesión',
                            onPressed: _login,
                          ),
                          const SizedBox(height: 48), // Espacio añadido
                          Text(
                            'V1.0.0',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sistema de Gestión de Farmacia - IESP',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
