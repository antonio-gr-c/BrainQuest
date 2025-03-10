import 'package:flutter/material.dart';
import '../widgets/pregunta_display.dart';

class CineScreen extends StatelessWidget {
  const CineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreguntaDisplay(
      categoria: 'Cine',
      colorCategoria: Color(0xFF2196F3), // Azul
    );
  }
} 