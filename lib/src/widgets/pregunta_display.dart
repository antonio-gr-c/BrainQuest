import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pregunta_controller.dart';
import 'loading_overlay.dart';

class PreguntaDisplay extends StatelessWidget {
  final String categoria;
  final Color colorCategoria;

  const PreguntaDisplay({
    super.key,
    required this.categoria,
    required this.colorCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreguntaController>();
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.045;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoria.toUpperCase(),
          style: TextStyle(fontSize: fontSize),
        ),
        backgroundColor: colorCategoria,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorCategoria.withOpacity(0.7),
                  const Color(0xFF1E1E2E),
                ],
              ),
            ),
            child: Obx(() => controller.isLoading.value
              ? const SizedBox()
              : Padding(
                padding: EdgeInsets.all(screenSize.width * 0.05),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenSize.width * 0.04),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(screenSize.width * 0.05),
                            child: Text(
                              controller.pregunta.value,
                              style: TextStyle(
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.opciones.length,
                        itemBuilder: (context, index) {
                          Color buttonColor = colorCategoria;
                          if (controller.respondido.value) {
                            if (index == controller.respuestaCorrecta.value) {
                              buttonColor = Colors.green;
                            } else {
                              buttonColor = Colors.red;
                            }
                          }
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 200 + (index * 100)),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) => Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenSize.height * 0.01,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: controller.respondido.value 
                                        ? null 
                                        : () => controller.verificarRespuesta(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      disabledBackgroundColor: buttonColor,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenSize.width * 0.05,
                                        vertical: screenSize.height * 0.02,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                                      ),
                                    ),
                                    child: Text(
                                      controller.opciones[index],
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => controller.respondido.value
            ? TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: (controller.ultimaRespuestaCorrecta.value 
                      ? Colors.green 
                      : Colors.red).withOpacity(0.8 * value),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(screenSize.width * 0.05),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.ultimaRespuestaCorrecta.value 
                                ? '¡CORRECTO!' 
                                : 'INCORRECTO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize * 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.03),
                          Card(
                            color: Colors.white.withOpacity(0.9),
                            child: Padding(
                              padding: EdgeInsets.all(screenSize.width * 0.04),
                              child: Column(
                                children: [
                                  Text(
                                    '¿Sabías que...?',
                                    style: TextStyle(
                                      fontSize: fontSize * 1.2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: screenSize.height * 0.02),
                                  Text(
                                    controller.datoCurioso.value,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.04),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  controller.isLoading.value = true;
                                  Get.back();
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Seguir Jugando'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenSize.width * 0.08,
                                    vertical: screenSize.height * 0.02,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
          ),
          Obx(() => controller.isLoading.value
            ? const LoadingOverlay()
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
} 