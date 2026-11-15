// Convertir JSON en datos Dart
import 'dart:convert';

// Importar Cloud Firestore y Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// Importar widgets de Flutter
import 'package:flutter/material.dart';
// Realizar peticiones HTTP
import 'package:http/http.dart' as http;

// Opciones de configuración de Firebase
import 'firebase_options.dart';

// Iniciar la aplicación e inicializar Firebase
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AplicacionFlutter());
}

// Modelo de datos para una película almacenada en Cloud Firestore
class Pelicula {
  final String id;
  final String titulo;
  final String genero;
  final String anio;
  final DateTime fechaCreacion;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.genero,
    required this.anio,
    required this.fechaCreacion,
  });

  factory Pelicula.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Pelicula(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      genero: data['genero'] as String? ?? '',
      anio: data['anio'] as String? ?? '',
      fechaCreacion: data['fechaCreacion'] is Timestamp
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titulo': titulo,
      'genero': genero,
      'anio': anio,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}

// Servicio para gestionar las operaciones en Cloud Firestore
class PeliculaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _peliculasRef => _db.collection('peliculas');

  // Agregar una nueva película a Firestore
  Future<void> agregarPelicula(Pelicula pelicula) async {
    await _peliculasRef.add(pelicula.toFirestore());
  }

  // Obtener el flujo en tiempo real de las películas registradas
  Stream<List<Pelicula>> obtenerPeliculasStream() {
    return _peliculasRef.snapshots().map((snapshot) {
      final peliculas =
          snapshot.docs.map((doc) => Pelicula.fromFirestore(doc)).toList();
      peliculas.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      return peliculas;
    });
  }

  // Eliminar una película por su ID de documento
  Future<void> eliminarPelicula(String id) async {
    await _peliculasRef.doc(id).delete();
  }
}

// Configuración de la aplicación principal
class AplicacionFlutter extends StatelessWidget {
  const AplicacionFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicio(),
    );
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
  final nombres = ['Pikachu', 'Mewtwo', 'Psyduck', 'Mr. Mime'];

  // Nombres utilizados por PokeAPI
  final rutas = ['pikachu', 'mewtwo', 'psyduck', 'mr-mime'];

  // Guardar imágenes obtenidas
  late Future<List<String>> imagenes;

  // Servicio de Firestore y controladores de formulario
  final PeliculaService _peliculaService = PeliculaService();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Realizar peticiones al abrir la app
    imagenes = obtenerImagenes();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _generoController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  // Obtener las imágenes de los personajes desde la API
  Future<List<String>> obtenerImagenes() async {
    final resultado = <String>[];

    // Realizar petición para cada personaje
    for (final ruta in rutas) {
      final respuesta = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$ruta'),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);

        // Guardar dirección de la imagen
        resultado.add(datos['sprites']['front_default']);
      } else {
        throw Exception('No se pudo obtener los datos');
      }
    }

    return resultado;
  }

  // Guardar los datos del formulario en Firebase Cloud Firestore
  Future<void> _guardarPelicula() async {
    final titulo = _tituloController.text.trim();
    final genero = _generoController.text.trim();
    final anio = _anioController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el título de la película')),
      );
      return;
    }

    try {
      final nuevaPelicula = Pelicula(
        id: '',
        titulo: titulo,
        genero: genero.isEmpty ? 'General' : genero,
        anio: anio.isEmpty ? '2026' : anio,
        fechaCreacion: DateTime.now(),
      );

      await _peliculaService.agregarPelicula(nuevaPelicula);

      _tituloController.clear();
      _generoController.clear();
      _anioController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película agregada a Firebase correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar en Firebase: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo.
          Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),

          // Oscurecer el fondo
          Container(color: Colors.black54),

          // Contenido principal desplazable
          SingleChildScrollView(
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

                    return Wrap(
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
                    );
                  },
                ),

                const SizedBox(height: 32),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),

                // Sección para agregar películas a Firebase Cloud Firestore
                const Text(
                  'Agregar película a Firebase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título de la película',
                            prefixIcon: Icon(Icons.movie),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _generoController,
                                decoration: const InputDecoration(
                                  labelText: 'Género',
                                  prefixIcon: Icon(Icons.category),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _anioController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Año',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardarPelicula,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Guardar en Firestore'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Películas guardadas en Firebase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Mostrar las películas registradas en tiempo real desde Firestore
                StreamBuilder<List<Pelicula>>(
                  stream: _peliculaService.obtenerPeliculasStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Error al conectar con Firebase Firestore.',
                        style: TextStyle(color: Colors.amberAccent),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final peliculas = snapshot.data ?? [];

                    if (peliculas.isEmpty) {
                      return const Text(
                        'Aún no hay películas registradas en la base de datos.',
                        style: TextStyle(color: Colors.white70),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: peliculas.length,
                      itemBuilder: (context, index) {
                        final pelicula = peliculas[index];
                        return Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.local_movies),
                            title: Text(
                              pelicula.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${pelicula.genero} • ${pelicula.anio}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _peliculaService.eliminarPelicula(pelicula.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
