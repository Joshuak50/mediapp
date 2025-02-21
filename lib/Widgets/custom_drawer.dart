import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapp/Pages/ListMedicamentos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Pages/Home.dart';
import '../Pages/Login.dart';
import '../Utilerias/Ambiente.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? nombreUsuario;
  String? fotoPerfil;

  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_usuario'); // Recupera el id_usuario guardado
  }

  Future<void> obtenerDatosUsuario() async {
    try {
      final idUsuario = await obtenerIdUsuario();
      if (idUsuario != null) {
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
            nombreUsuario = data['nombre'];
            fotoPerfil = data['imagen'];
          });
        } else {
          print('Error al obtener datos del usuario: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: fotoPerfil != null
                      ? NetworkImage(fotoPerfil!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  nombreUsuario ?? 'Cargando...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Inicio'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home())
              );
            },
          ),
          ListTile(
            title: const Text('Medicamentos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Listmedicamentos()),
              );
            },
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Limpia las preferencias almacenadas.

              // Redirige al usuario a la pantalla de inicio de sesión
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()), // Redirige a la vista de login
                    (route) => true, // Elimina todas las rutas anteriores
              );
            },
          ),
        ],
      ),
    );
  }
}
