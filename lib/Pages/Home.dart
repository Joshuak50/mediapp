import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mediapp/Widgets/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utilerias/Ambiente.dart';
import '../Widgets/custom_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? nombreUsuario;
  String? fotoPerfil;

  // Función para obtener el idUsuario desde SharedPreferences
  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_usuario');  // Recupera el id_usuario guardado
  }

  //Inicializador
  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
    obtenerIdUsuario().then((idUsuario) {
      if (idUsuario != null) {
        //fnObtenerCategorias();
      } else {
        print('No se encontró el ID del usuario');
      }
    });
  }

  Future<void> obtenerDatosUsuario() async {
    try {
      final idUsuario = await obtenerIdUsuario();
      if (idUsuario != null) {
        // Llamada a la API para obtener datos del usuario
        final response = await http.get(
          Uri.parse('${Ambiente.urlServe}/api/usuario/$idUsuario'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            nombreUsuario = data['nombre']; // Suponiendo que el JSON tiene "nombre"
            fotoPerfil = data['imagen']; // Suponiendo que el JSON tiene "foto"
            print('URL de la imagen: $fotoPerfil');

          });
        } else {
          print('Error al obtener datos del usuario: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> testImageUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("Imagen cargada correctamente");
      } else {
        print("Error al cargar imagen: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al acceder a la imagen: $e");
    }
  }
//------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Inicio"),
        ),
        drawer: CustomDrawer(),
        body: Container( // Agregamos un Container para definir el fondo
            color: Color(0xFFF5F5DC), // Código de color beige
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2895/2895710.png', // Ruta de la imagen
                      width: 200, // Ajusta el tamaño según lo necesites
                      height: 200,
                    ),
                    const SizedBox(height: 20), // Espaciado entre la imagen y el texto
                    const Text(
                      'Bienvenido a MediApp, una aplicacion para recordar cuando tomar tus medicinas',
                      style: TextStyle(fontSize: 18),
                    ),
                  ]
              ),
            )
        )
    );
  }

}
