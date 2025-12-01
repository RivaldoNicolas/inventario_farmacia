import 'package:flutter/material.dart';

//Tarjeta de acción rápida reutilizable
class AccionRapidaCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;
  //Constructor de la tarjeta de acción rápida
  const AccionRapidaCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  });
  //Construye la tarjeta de acción rápida
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
