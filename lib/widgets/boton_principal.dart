import 'package:flutter/material.dart';

// Widget personalizado para el botón principal con estilo consistente
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  // Constructor que recibe el texto y la acción al presionar
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
  });
  // Método que construye el widget
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(5),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? Colors.white.withOpacity(0.2)
                : null,
          ),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondary,
                Color.lerp(
                  Theme.of(context).colorScheme.secondary,
                  Colors.black,
                  0.2,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
