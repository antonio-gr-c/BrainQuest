import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/ruleta_controller.dart';
import 'loading_overlay.dart';

class RuletaWidget extends StatelessWidget {
  const RuletaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RuletaController>();
    final screenSize = MediaQuery.of(context).size;
    final ruletaSize = screenSize.width * 0.85;

    return Obx(() => Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: ruletaSize,
                    height: ruletaSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: controller.escala.value,
                          child: Transform.rotate(
                            angle: controller.rotacion.value,
                            child: Container(
                              width: ruletaSize,
                              height: ruletaSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                size: Size(ruletaSize, ruletaSize),
                                painter: RuletaPainter(
                                  categoriaSeleccionada: controller.seleccionado.value,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        Align(
                          alignment: Alignment.topCenter,
                          child: Transform.translate(
                            offset: Offset(0, -ruletaSize * 0.03),
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 200),
                              tween: Tween<double>(
                                begin: 1.0,
                                end: controller.isSpinning.value ? 0.8 : 1.0,
                              ),
                              builder: (context, value, child) => Transform.scale(
                                scale: value,
                                child: Container(
                                  width: ruletaSize * 0.15,
                                  height: ruletaSize * 0.15,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    size: ruletaSize * 0.1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.05),
                ElevatedButton(
                  onPressed: controller.isSpinning.value || controller.isTransitioning.value 
                      ? null 
                      : controller.girarAleatorio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(
                      horizontal: ruletaSize * 0.08,
                      vertical: ruletaSize * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ruletaSize * 0.05),
                    ),
                  ),
                  child: Text(
                    'Girar Ruleta',
                    style: TextStyle(
                      fontSize: ruletaSize * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.05),
              ],
            ),
          ),
        ),
        if (controller.isTransitioning.value)
          const LoadingOverlay(),
      ],
    ));
  }
}

class RuletaPainter extends CustomPainter {
  final List<Color> colores = [
    const Color(0xFFFFA726),  // Naranja para Historia
    const Color(0xFFE91E63),  // Rosa para Deportes
    const Color(0xFF4CAF50),  // Verde para Ciencias
    const Color(0xFF2196F3),  // Azul para Cine
  ];

  final List<Map<String, dynamic>> categorias = [
    {'texto': 'Historia', 'icono': Icons.book},
    {'texto': 'Deportes', 'icono': Icons.sports_soccer},
    {'texto': 'Ciencias', 'icono': Icons.science},
    {'texto': 'Cine', 'icono': Icons.movie},
  ];

  final Map<int, String> indiceACategoria = {
    0: '2', // Historia es 2
    1: '3', // Deportes es 3
    2: '4', // Ciencias es 4
    3: '1', // Cine es 1
  };

  final String categoriaSeleccionada;

  RuletaPainter({
    required this.categoriaSeleccionada,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dibuja las secciones de la ruleta
    for (var i = 0; i < 4; i++) {
      final paint = Paint()..color = colores[i];
      final startAngle = i * (math.pi / 2) - math.pi / 4;
      canvas.drawArc(rect, startAngle, math.pi / 2, true, paint);

      // Dibuja la categoría y el ícono
      final textAngle = startAngle + math.pi / 4;
      canvas.save();
      canvas.translate(
        center.dx + (radius * 0.6) * math.cos(textAngle),
        center.dy + (radius * 0.6) * math.sin(textAngle),
      );
      canvas.rotate(textAngle + math.pi / 2);

      // Dibuja el texto
      final textPainter = TextPainter(
        text: TextSpan(
          text: categorias[i]['texto'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height - 5),
      );

      // Dibuja el ícono
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode((categorias[i]['icono'] as IconData).codePoint),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: (categorias[i]['icono'] as IconData).fontFamily,
            package: (categorias[i]['icono'] as IconData).fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(-iconPainter.width / 2, 5),
      );
      canvas.restore();
    }

    // Dibuja el borde de la ruleta
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Dibuja el círculo central
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 15, centerPaint);
  }

  @override
  bool shouldRepaint(covariant RuletaPainter oldDelegate) {
    return oldDelegate.categoriaSeleccionada != categoriaSeleccionada;
  }
} 