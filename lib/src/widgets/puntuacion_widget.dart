import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pregunta_controller.dart';

class PuntuacionWidget extends StatelessWidget {
  const PuntuacionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PreguntaController>();
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.045; // 4.5% del ancho de la pantalla

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(screenSize.width * 0.08),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Puntos con animación
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: fontSize * 1.2),
                SizedBox(width: screenSize.width * 0.02),
                Obx(() => TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 500),
                  tween: IntTween(
                    begin: 0,
                    end: controller.puntos.value,
                  ),
                  builder: (context, value, child) => Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(width: screenSize.width * 0.06),
            // Vidas con corazones animados
            Row(
              children: [
                Obx(() => Row(
                  children: List.generate(3, (index) {
                    bool estaLleno = index < controller.vidas.value;
                    return TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween<double>(
                        begin: estaLleno ? 0.0 : 1.0,
                        end: estaLleno ? 1.0 : 0.0,
                      ),
                      builder: (context, value, child) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.005,
                        ),
                        child: Icon(
                          estaLleno ? Icons.favorite : Icons.favorite_border,
                          color: Color.lerp(
                            Colors.grey,
                            Colors.red,
                            value,
                          ),
                          size: fontSize + (value * 4),
                        ),
                      ),
                    );
                  }),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 