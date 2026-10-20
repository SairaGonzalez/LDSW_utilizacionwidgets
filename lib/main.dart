// Importa los widgets de Flutter de Material Design
import 'package:flutter/material.dart';

// Iniciar la aplicación
void main() {
  runApp(const AplicacionFlutter());
}

// Aplicación principal
class AplicacionFlutter extends StatelessWidget {
  const AplicacionFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Container: configurar el fondo, el padding y la alineación
        body: Container(
          color: const Color(0xFF0D2A5F),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,

          // Column: organizar los elementos verticalmente
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text: mostrar texto en la pantalla
              const Text(
                "Bienvenido a Flutter",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),

              // Row: organizar los elementos horizontalmente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    color: const Color(0xFFC3DEF8),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Elemento A",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFC7F2FF),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Elemento B",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Stack: colocar los widgets uno sobre otro
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 60,
                    color: const Color(0xFF97B0C5),
                  ),
                  Text("Hola mundo", style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
