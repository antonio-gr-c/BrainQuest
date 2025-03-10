import 'package:get/get.dart';
import '../services/deepseek_service.dart';
import 'package:flutter/material.dart';
import 'game_controller.dart';

class PreguntaController extends GetxController {
  final pregunta = ''.obs;
  final opciones = <String>[].obs;
  final respuestaCorrecta = 0.obs;
  final respondido = false.obs;
  final ultimaRespuestaCorrecta = false.obs;
  final puntos = 0.obs;
  final vidas = 3.obs;
  final datoCurioso = ''.obs;
  final isLoading = false.obs;
  final RxString nivelDificultad = 'fácil'.obs;
  final mostrarBotonContinuar = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
  }

  Future<void> cargarPreguntaDeCategoria(String categoria, Color colorCategoria) async {
    isLoading.value = true;
    mostrarBotonContinuar.value = false;
    
    try {
      final preguntaData = await DeepseekService.generarPregunta(
        categoria,
        puntos: Get.find<GameController>().puntos.value,
      );
      
      pregunta.value = preguntaData['pregunta'];
      opciones.value = List<String>.from(preguntaData['opciones']);
      respuestaCorrecta.value = preguntaData['respuestaCorrecta'];
      datoCurioso.value = preguntaData['datoCurioso'];
      respondido.value = false;
      ultimaRespuestaCorrecta.value = false;

      if (puntos.value >= 15) {
        nivelDificultad.value = 'muy difícil';
      } else if (puntos.value >= 10) {
        nivelDificultad.value = 'difícil';
      } else if (puntos.value >= 5) {
        nivelDificultad.value = 'media';
      } else {
        nivelDificultad.value = 'fácil';
      }

      // Mostrar mensaje de cambio de dificultad si existe
      if (preguntaData.containsKey('mensajeDificultad')) {
        final mensajeDificultad = preguntaData['mensajeDificultad'];
        Get.snackbar(
          mensajeDificultad['titulo'],
          mensajeDificultad['mensaje'],
          backgroundColor: colorCategoria,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 20,
          icon: const Icon(Icons.star, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la pregunta: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void verificarRespuesta(int indice) {
    if (!respondido.value) {
      respondido.value = true;
      ultimaRespuestaCorrecta.value = indice == respuestaCorrecta.value;

      if (ultimaRespuestaCorrecta.value) {
        puntos.value++;
        Future.delayed(const Duration(seconds: 2), () {
          mostrarBotonContinuar.value = true;
        });
      } else {
        vidas.value--;
        if (vidas.value <= 0) {
          Future.delayed(const Duration(seconds: 2), () {
            Get.dialog(
              AlertDialog(
                title: const Text('¡Juego Terminado!'),
                content: Text('Puntuación final: ${puntos.value}\nNivel alcanzado: ${nivelDificultad.value}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      reiniciarJuego();
                      Get.back();
                      Get.back();
                    },
                    child: const Text('Volver a jugar'),
                  ),
                ],
              ),
            );
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            mostrarBotonContinuar.value = true;
          });
        }
      }
    }
  }

  void reiniciarJuego() {
    puntos.value = 0;
    vidas.value = 3;
    nivelDificultad.value = 'fácil';
    respondido.value = false;
    mostrarBotonContinuar.value = false;
    isLoading.value = true;
  }
} 