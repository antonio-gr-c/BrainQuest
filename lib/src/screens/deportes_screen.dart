import 'package:flutter/material.dart';
import '../widgets/pregunta_display.dart';

class DeportesScreen extends StatelessWidget {
  const DeportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreguntaDisplay(
      categoria: 'Deportes',
      colorCategoria: Color(0xFFE91E63), // Rosa/Rojo
    );
  }
} 