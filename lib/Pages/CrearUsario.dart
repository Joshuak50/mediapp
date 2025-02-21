import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Utilerias/Ambiente.dart';


class CrearUsuario extends StatefulWidget {
  const CrearUsuario({super.key});

  @override
  State<CrearUsuario> createState() => _CrearUsuarioState();
}

class _CrearUsuarioState extends State<CrearUsuario> {
  final TextEditingController txtNombre = TextEditingController();
  final TextEditingController txtCorreo = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Método para seleccionar una imagen
  Future<void> seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  // Método para guardar usuario
  Future<void> guardarUsuario() async {
    if (txtNombre.text.isEmpty ||
        txtCorreo.text.isEmpty ||
        txtContrasena.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    // Validar formato de correo electrónico
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(txtCorreo.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un correo válido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Ambiente.urlServe}/api/usuarios/guardar'),
      );

      if (_imagenSeleccionada != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagen',
          _imagenSeleccionada!.path,
        ));
      }

      request.fields['nombre'] = txtNombre.text;
      request.fields['correo'] = txtCorreo.text;
      request.fields['contrasena'] = txtContrasena.text;

      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario guardado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el usuario: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Crear Usuario"),
        ),
        body: Container( // Agregamos un Container para definir el fondo
          color: Color(0xFFF5F5DC),
          width: 1100, // Opcional
          height: 1000,// Código de color beige
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imagenSeleccionada == null)
                    const Text("No se ha seleccionado una imagen")
                  else
                    Image.file(
                      _imagenSeleccionada!,
                      height: 300,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: seleccionarImagen,
                    child: const Text("Seleccionar Imagen"),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: txtNombre,
                    decoration: const InputDecoration(
                      labelText: "Nombre Completo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: txtCorreo,
                    decoration: const InputDecoration(
                      labelText: "Correo Electrónico",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: txtContrasena,
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: guardarUsuario,
                    child: const Text("Registrar Usuario"),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}