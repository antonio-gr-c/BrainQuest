import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/screens/home_screen.dart';
import 'src/controllers/game_controller.dart';

void main() {
  // Inicializa el controlador del juego
  Get.put(GameController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrainQuest',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),       // Azul brillante
          secondary: Color(0xFF64B5F6),     // Azul claro
          tertiary: Color(0xFF1976D2),      // Azul oscuro
          surface: Color(0xFF1E1E2E),    // Azul negro
          error: Color(0xFFCF6679),         // Rojo oscuro
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E2E),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
