import 'package:flutter/material.dart';
import '../widgets/pregunta_display.dart';

class HistoriaScreen extends StatelessWidget {
  const HistoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreguntaDisplay(
      categoria: 'Historia',
      colorCategoria: Color(0xFFFFA726), // Naranja/Amarillo
    );
  }
} 