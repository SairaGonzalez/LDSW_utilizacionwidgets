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
        // Colocar los elementos uno sobre el otro con stack
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Mostrar la imagen de fondo
            Image.asset("assets/images/fondo.jpg", fit: BoxFit.cover),

            // Centrar el contenido en la pantalla
            Center(
              // Organizar los elementos verticalmente
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mostrar el nombre de la app
                  const Text(
                    "Catálogo de películas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mostrar un ícono
                  const Icon(Icons.movie, color: Colors.white, size: 50),
                  const SizedBox(height: 16),

                  // Mostrar el mensaje
                  const Text(
                    "Hello World",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
