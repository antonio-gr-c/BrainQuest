import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class DeepseekService {
  static const String apiKey = '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';
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static final _random = math.Random();
  static const int maxIntentos = 3;

  static Map<String, dynamic> _mezclarOpciones(Map<String, dynamic> pregunta) {
    final List<int> indices = List.generate(4, (index) => index);
    indices.shuffle(_random);
    
    final List<String> opcionesOriginales = List<String>.from(pregunta['opciones']);
    final int respuestaOriginal = pregunta['respuestaCorrecta'];
    
    final List<String> opcionesMezcladas = [];
    int nuevaRespuestaCorrecta = 0;
    
    for (int i = 0; i < indices.length; i++) {
      opcionesMezcladas.add(opcionesOriginales[indices[i]]);
      if (indices[i] == respuestaOriginal) {
        nuevaRespuestaCorrecta = i;
      }
    }
    
    return {
      'pregunta': pregunta['pregunta'],
      'opciones': opcionesMezcladas,
      'respuestaCorrecta': nuevaRespuestaCorrecta,
      'datoCurioso': pregunta['datoCurioso'],
    };
  }

  static String _obtenerDificultad(int puntos) {
    if (puntos >= 15) return "muy difícil";
    if (puntos >= 10) return "difícil";
    if (puntos >= 5) return "media";
    return "fácil";
  }

  static Map<String, String> _obtenerMensajeDificultad(int puntos) {
    if (puntos == 5) {
      return {
        'titulo': '¡Nivel Intermedio Desbloqueado!',
        'mensaje': 'Las preguntas serán un poco más desafiantes ahora.'
      };
    } else if (puntos == 10) {
      return {
        'titulo': '¡Nivel Difícil Desbloqueado!',
        'mensaje': 'Prepárate para preguntas más complejas.'
      };
    } else if (puntos == 15) {
      return {
        'titulo': '¡Nivel Experto Desbloqueado!',
        'mensaje': '¡Las preguntas serán realmente desafiantes!'
      };
    }
    return {};
  }

  static String _obtenerInstruccionesAdicionales(String categoria, String dificultad) {
    final Map<String, String> instrucciones = {
      'Cine': '''
        Para preguntas de cine, incluye variedad de:
        - Diferentes épocas del cine
        - Diversos géneros cinematográficos
        - Directores, actores y películas internacionales
        - Aspectos técnicos del cine para dificultad alta
      ''',
      'Historia': '''
        Para preguntas de historia, incluye:
        - Diferentes períodos históricos
        - Diversos lugares del mundo
        - Eventos significativos
        - Aspectos culturales y sociales para dificultad alta
      ''',
      'Deportes': '''
        Para preguntas de deportes, incluye:
        - Diferentes disciplinas deportivas
        - Eventos deportivos históricos
        - Atletas destacados
        - Reglas y técnicas para dificultad alta
      ''',
      'Ciencias': '''
        Para preguntas de ciencias, incluye:
        - Diferentes ramas científicas
        - Descubrimientos importantes
        - Científicos destacados
        - Conceptos técnicos para dificultad alta
      '''
    };

    return instrucciones[categoria] ?? '';
  }

  static String _generarSemillaUnica() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = _random.nextInt(1000000000);
    return '$timestamp-$randomNum';
  }

  static Future<Map<String, dynamic>> generarPregunta(String categoria, {int puntos = 0, int intento = 0}) async {
    if (intento >= maxIntentos) {
      return {
        'pregunta': '¿Estás listo para una pregunta de $categoria?',
        'opciones': ['Sí, adelante', 'Por supuesto', 'Estoy preparado', 'Definitivamente'],
        'respuestaCorrecta': 0,
        'datoCurioso': '¡Vamos a aprender algo nuevo!'
      };
    }

    final dificultad = _obtenerDificultad(puntos);
    final mensajeDificultad = _obtenerMensajeDificultad(puntos);

    final prompt = '''Genera una pregunta de trivia única y creativa para la categoría "$categoria" con dificultad "$dificultad".
    La pregunta debe ser diferente a las anteriores y ajustarse al nivel de dificultad:
    - Fácil: preguntas básicas y directas
    - Media: preguntas con más detalles y opciones más similares
    - Difícil: preguntas que requieren conocimiento específico
    - Muy difícil: preguntas que requieren conocimiento profundo y detallado

    Formato JSON requerido:
    {
      "pregunta": "pregunta específica y única",
      "opciones": ["opción correcta", "opción 2", "opción 3", "opción 4"],
      "respuestaCorrecta": 0,
      "datoCurioso": "dato interesante y poco conocido"
    }
    
    Instrucciones:
    - Ajusta la complejidad según el nivel de dificultad
    - Las opciones incorrectas deben ser plausibles
    - El dato curioso debe ser relevante y poco conocido''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
          'HTTP-Referer': 'https://brainquest.com',
          'X-Title': 'BrainQuest',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': 'mistralai/mistral-7b-instruct:free',
          'messages': [
            {
              'role': 'system',
              'content': 'Genera preguntas de trivia ajustadas al nivel de dificultad especificado.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 200,
          'temperature': 0.7,
          'top_p': 0.8
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
          final contenido = jsonResponse['choices'][0]['message']['content'];
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(contenido);
          if (jsonMatch != null) {
            try {
              final preguntaJson = jsonMatch.group(0)!;
              final pregunta = jsonDecode(preguntaJson);
              if (_validarFormatoPregunta(pregunta)) {
                pregunta['pregunta'] = _limpiarTexto(pregunta['pregunta']);
                pregunta['opciones'] = (pregunta['opciones'] as List).map((e) => _limpiarTexto(e.toString())).toList();
                pregunta['datoCurioso'] = _limpiarTexto(pregunta['datoCurioso'] ?? '¡Interesante pregunta!');
                
                // Agregar mensaje de cambio de dificultad si existe
                if (mensajeDificultad.isNotEmpty) {
                  pregunta['mensajeDificultad'] = mensajeDificultad;
                }
                
                return _mezclarOpciones(pregunta);
              }
            } catch (e) {
              print('Error al parsear JSON: $e');
            }
          }
        }
        print('Error en el formato de la respuesta: $jsonResponse');
        return generarPregunta(categoria, puntos: puntos, intento: intento + 1);
      } else {
        print('Error de API: ${response.statusCode} - ${response.body}');
        return generarPregunta(categoria, puntos: puntos, intento: intento + 1);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      return generarPregunta(categoria, puntos: puntos, intento: intento + 1);
    }
  }

  static String _limpiarTexto(String texto) {
    final reemplazos = {
      '´': '', '`': '', '¨': '', '~': '',
      '"': '"', '"': '"', ''': "'", ''': "'",
      '–': '-', '—': '-',
      '…': '...'
    };

    String resultado = texto;
    reemplazos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });
    
    resultado = resultado.replaceAll(RegExp(r'[^\x00-\x7F\xC0-\xFF\u00F1\u00D1]'), '');
    
    return resultado.trim();
  }

  static bool _validarFormatoPregunta(Map<String, dynamic> pregunta) {
    try {
      return pregunta.containsKey('pregunta') &&
             pregunta.containsKey('opciones') &&
             pregunta.containsKey('respuestaCorrecta') &&
             pregunta.containsKey('datoCurioso') &&
             pregunta['opciones'] is List &&
             (pregunta['opciones'] as List).length == 4 &&
             pregunta['respuestaCorrecta'] is int &&
             pregunta['respuestaCorrecta'] >= 0 &&
             pregunta['respuestaCorrecta'] < 4;
    } catch (e) {
      print('Error en validación: $e');
      return false;
    }
  }

  static String _obtenerSubtema(String categoria, int semilla) {
    final subtemas = {
      'Cine': [
        'Cine clásico', 'Cine moderno', 'Directores', 'Actores',
        'Películas de culto', 'Géneros específicos', 'Premios y festivales',
        'Técnicas cinematográficas', 'Cine internacional', 'Efectos especiales',
        'Bandas sonoras', 'Documentales', 'Animación', 'Cine independiente',
        'Guionistas', 'Productoras', 'Movimientos cinematográficos',
        'Adaptaciones', 'Series', 'Cortometrajes'
      ],
      'Historia': [
        'Edad Antigua', 'Edad Media', 'Renacimiento', 'Era Moderna',
        'Siglo XX', 'Guerras', 'Revoluciones', 'Personajes históricos',
        'Civilizaciones', 'Inventos', 'Arte histórico', 'Religiones',
        'Exploraciones', 'Política', 'Economía', 'Cultura',
        'Arqueología', 'Dinastías', 'Imperios', 'Descubrimientos'
      ],
      'Deportes': [
        'Fútbol', 'Baloncesto', 'Tenis', 'Atletismo',
        'Natación', 'Boxeo', 'Fórmula 1', 'Ciclismo',
        'Olimpiadas', 'Deportes extremos', 'Deportes de equipo',
        'Records mundiales', 'Historia deportiva', 'Reglas',
        'Equipamiento', 'Estrategias', 'Entrenamiento',
        'Competiciones', 'Deportistas famosos', 'Lesiones'
      ],
      'Ciencias': [
        'Física', 'Química', 'Biología', 'Astronomía',
        'Matemáticas', 'Medicina', 'Geología', 'Tecnología',
        'Ecología', 'Genética', 'Neurociencia', 'Paleontología',
        'Botánica', 'Zoología', 'Climatología', 'Oceanografía',
        'Microbiología', 'Evolución', 'Química orgánica', 'Física cuántica'
      ]
    };

    final listaSubtemas = subtemas[categoria] ?? subtemas['Ciencias']!;
    return listaSubtemas[semilla % listaSubtemas.length];
  }

  static Future<String> generarPista(String pregunta, String respuestaCorrecta) async {
    final prompt = '''Eres un experto en dar pistas sutiles pero útiles.

INSTRUCCIONES:
1. Analiza la siguiente pregunta y su respuesta correcta
2. Genera una pista que ayude a pensar en la dirección correcta
3. La pista no debe revelar directamente la respuesta
4. Debe ser una frase corta y clara
5. Usa español con acentos y ñ

Pregunta: $pregunta
Respuesta correcta: $respuestaCorrecta

Responde solo con la pista, sin ningún otro texto.''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
          'HTTP-Referer': 'https://brainquest.com',
          'X-Title': 'BrainQuest',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': 'mistralai/mistral-7b-instruct:free',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un experto en dar pistas sutiles pero útiles para preguntas de trivia.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 100,
          'temperature': 0.7,
          'top_p': 0.9
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
          final pista = jsonResponse['choices'][0]['message']['content'].toString().trim();
          return _limpiarTexto(pista);
        }
      }
      return 'Piensa bien en la pregunta...';
    } catch (e) {
      print('Error al generar pista: $e');
      return 'Piensa bien en la pregunta...';
    }
  }
} 