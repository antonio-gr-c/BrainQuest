import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../screens/cine_screen.dart';
import '../screens/historia_screen.dart';
import '../screens/deportes_screen.dart';
import '../screens/ciencias_screen.dart';
import 'pregunta_controller.dart';

class RuletaController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animationController;
  final rotacion = 0.0.obs;
  final escala = 1.0.obs;
  final isSpinning = false.obs;
  final seleccionado = '1'.obs;
  final isTransitioning = false.obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    animationController.addListener(() {
      rotacion.value = curvedAnimation.value * _targetRotation;
      // Efecto de escala: la ruleta crece hasta 1.1 en la mitad del giro y vuelve a su tamaño
      double progress = curvedAnimation.value;
      if (progress <= 0.5) {
        escala.value = 1.0 + (progress * 0.1); // Crece hasta 1.1
      } else {
        escala.value = 1.1 - ((progress - 0.5) * 0.2); // Decrece a 1.0
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  double _targetRotation = 0.0;

  void girarAleatorio() {
    if (!isSpinning.value && !isTransitioning.value) {
      final random = math.Random();
      final numero = random.nextInt(4) + 1;
      girarHacia(numero);
    }
  }

  void girarHacia(int numero) {
    if (!isSpinning.value && !isTransitioning.value) {
      isSpinning.value = true;
      seleccionado.value = numero.toString();

      final anguloBase = -(numero - 1) * (math.pi / 2);
      final vueltasExtra = 4 + math.Random().nextInt(3);
      _targetRotation = (vueltasExtra * 2 * math.pi) + anguloBase;

      animationController.reset();
      animationController.forward().then((_) async {
        isSpinning.value = false;
        isTransitioning.value = true;
        await Future.delayed(const Duration(milliseconds: 500));
        _navegarAPantalla(seleccionado.value);
      });
    }
  }

  void _navegarAPantalla(String categoria) async {
    if (!Get.isRegistered<PreguntaController>()) {
      Get.put(PreguntaController());
    }

    final preguntaController = Get.find<PreguntaController>();
    preguntaController.isLoading.value = true;
    String categoriaTexto = '';

    switch (categoria) {
      case '1':
        categoriaTexto = 'Cine';
        await preguntaController.cargarPreguntaDeCategoria('Cine', const Color(0xFFE91E63));
        Get.to(() => const CineScreen(), transition: Transition.fadeIn);
        break;
      case '2':
        categoriaTexto = 'Historia';
        await preguntaController.cargarPreguntaDeCategoria('Historia', const Color(0xFF9C27B0));
        Get.to(() => const HistoriaScreen(), transition: Transition.fadeIn);
        break;
      case '3':
        categoriaTexto = 'Deportes';
        await preguntaController.cargarPreguntaDeCategoria('Deportes', const Color(0xFF4CAF50));
        Get.to(() => const DeportesScreen(), transition: Transition.fadeIn);
        break;
      case '4':
        categoriaTexto = 'Ciencias';
        await preguntaController.cargarPreguntaDeCategoria('Ciencias', const Color(0xFF2196F3));
        Get.to(() => const CienciasScreen(), transition: Transition.fadeIn);
        break;
    }
    isTransitioning.value = false;
  }
} 