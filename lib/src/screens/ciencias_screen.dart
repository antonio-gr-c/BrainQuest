import 'package:flutter/material.dart';
import '../widgets/pregunta_display.dart';

class CienciasScreen extends StatelessWidget {
  const CienciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreguntaDisplay(
      categoria: 'Ciencias',
      colorCategoria: Color(0xFF4CAF50), // Verde
    );
  }
} 