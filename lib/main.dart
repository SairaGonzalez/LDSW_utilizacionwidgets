// Convertir JSON en datos Dart
import "dart:convert";

// Importar widgets de Flutter
import "package:flutter/material.dart";

// Realizar peticiones HTTP
import "package:http/http.dart" as http;

// Iniciar la aplicación
void main() {
  runApp(const AplicacionFlutter());
}

// Configuración de la aplicación principal
class AplicacionFlutter extends StatelessWidget {
  const AplicacionFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: PantallaInicio());
  }
}

// Mostrar pantalla principal
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Nombres que se mostrarán en pantalla
  final nombres = ["Pikachu", "Mewtwo", "Psyduck", "Mr. Mime"];

  // Nombres utilizados por PokeAPI
  final rutas = ["pikachu", "mewtwo", "psyduck", "mr-mime"];

  // Guardar imágenes obtenidas
  late Future<List<String>> imagenes;

  @override
  void initState() {
    super.initState();

    // Realizar peticiones al abrir la app
    imagenes = obtenerImagenes();
  }

  // Obtener las imágenes de los personajes desde la API
  Future<List<String>> obtenerImagenes() async {
    final resultado = <String>[];

    // Realizar petición para cada personaje
    for (final ruta in rutas) {
      final respuesta = await http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/$ruta"),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);

        // Guardar dirección de la imagen
        resultado.add(datos["sprites"]["front_default"]);
      } else {
        throw Exception("No se pudo obtener los datos");
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de películas"),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo.
          Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),

          // Oscurecer el fondo
          Container(color: Colors.black45),

          // Mostrar la información obtenida desde PokéAPI.
          FutureBuilder<List<String>>(
            future: imagenes,
            builder: (context, datos) {
              if (datos.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (datos.hasError) {
                return const Center(
                  child: Text(
                    'No se pudo cargar la información.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/poster_pikachu.jpg',
                      height: 250,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pokémon Detective Pikachu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Personajes principales',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(nombres.length, (indice) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              datos.data![indice],
                              width: 100,
                              height: 100,
                            ),
                            Text(
                              nombres[indice],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
