import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      body: const Center(
        child: Text('Aquí irán los accesos directos y resúmenes.'),
      ),
    );
  }
}
