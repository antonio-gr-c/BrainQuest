import 'package:get/get.dart';
import 'dart:math' as math;

class CategoriaController extends GetxController {
  final RxString categoriaSeleccionada = ''.obs;
  
  final List<String> categorias = [
    'Historia',
    'Cine',
    'Deportes',
    'Ciencias',
  ];

  void seleccionarCategoriaAleatoria() {
    final random = math.Random();
    final index = random.nextInt(categorias.length);
    categoriaSeleccionada.value = categorias[index];
  }
} 