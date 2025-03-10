import 'package:get/get.dart';

class GameController extends GetxController {
  final RxInt puntos = 0.obs;
  final RxInt vidas = 3.obs;
  final RxString categoriaSeleccionada = ''.obs;

  void seleccionarCategoria(String categoria) {
    categoriaSeleccionada.value = categoria;
  }

  void incrementarPuntos(int cantidad) {
    puntos.value += cantidad;
  }

  void perderVida() {
    if (vidas.value > 0) {
      vidas.value--;
      if (vidas.value == 0) {
        // TODO: Implementar game over
        reiniciarJuego();
      }
    }
  }

  void reiniciarJuego() {
    puntos.value = 0;
    vidas.value = 3;
    categoriaSeleccionada.value = '';
  }
} 