import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/LoginResponse.dart';
import '../Utilerias/Ambiente.dart';
import 'CrearUsario.dart';
import 'Home.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

// Función para guardar el id_usuario en SharedPreferences
Future<void> guardarIdUsuario(int idUsuario) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id_usuario', idUsuario);// Guardar el id_usuario
  print('Token guardado: $idUsuario');
}

class _LoginState extends State<Login> {
  TextEditingController txtUser = TextEditingController();
  TextEditingController txtPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso'),
        ),
        body: Container( // Agregamos un Container para definir el fondo
          color: Color(0xFFF5F5DC),
          width: 1100, // Opcional
          height: 1000,// Código de color beige
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/i.png',
                  width: 100, // Opcional
                  height: 100, // Opcional
                  fit: BoxFit.cover, // Opcional
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: TextFormField(
                    controller: txtUser,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                  child: TextFormField(
                    controller: txtPass,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                    ),
                    obscureText: true,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final response = await http.post(
                      Uri.parse('${Ambiente.urlServe}/api/login'),
                      body: jsonEncode(<String, dynamic>{
                        'email': txtUser.text, // Aquí se utiliza el valor ingresado
                        'password': txtPass.text // Aquí se utiliza el valor ingresado
                      }),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8'
                      },
                    );

                    if (response.statusCode == 200) {
                      Map<String, dynamic> responseJson = jsonDecode(response.body);
                      final loginResponse = LoginResponse.fromJson(responseJson);
                      if (loginResponse.acceso == "ok") {
                        // Guardar el id_usuario de la respuesta de login
                        guardarIdUsuario(loginResponse.idUsuario);

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      } else {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Error',
                          text: loginResponse.error,
                        );
                      }
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Error de conexión',
                        text: 'No se pudo conectar al servidor',
                      );
                    }
                  },
                  child: const Text('Aceptar'),
                ),
                // Nuevo botón para crear usuario
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CrearUsuario(),
                      ),
                    );
                  },
                  child: const Text('Crear Usuario'),
                ),
              ],
            ),
          ),
        )
    );
  }
}
