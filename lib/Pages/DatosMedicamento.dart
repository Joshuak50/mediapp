import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mediapp/Models/Medicamentos.dart';
import 'package:mediapp/Pages/ListMedicamentos.dart';
import '../Utilerias/Ambiente.dart';

class Datosmedicamento extends StatefulWidget {
  final Medicamentos medicamentos;
  const Datosmedicamento({super.key, required this.medicamentos});

  @override
  State<Datosmedicamento> createState() => _DatosmedicamentoState();
}

class _DatosmedicamentoState extends State<Datosmedicamento> {
  late TextEditingController txtid;
  late TextEditingController txtnombre;
  late TextEditingController txtdesc;
  late TextEditingController txtfecha;
  late TextEditingController txthora;
  late TextEditingController txtdosis;
  late TextEditingController txtfrecu;
  late TextEditingController txtid_usuario;

  @override
  void initState() {
    super.initState();
    txtid = TextEditingController(text: widget.medicamentos.id.toString()); // Asignamos el ID de la categoría
    txtnombre = TextEditingController(text: widget.medicamentos.nombre);
    txtdesc = TextEditingController(text: widget.medicamentos.descripcion);
    txtfecha = TextEditingController(text: widget.medicamentos.fecha);
    txthora = TextEditingController(text: widget.medicamentos.hora);
    txtdosis = TextEditingController(text: widget.medicamentos.dosis);
    txtfrecu = TextEditingController(text: widget.medicamentos.frecuencia.toString());
    txtid_usuario = TextEditingController(text: widget.medicamentos.id_usuario.toString());
  }

  Future<void> fnActualizarCategoria() async {
    try {
      final response = await http.put(
        Uri.parse('${Ambiente.urlServe}/api/categoria/${widget.medicamentos.id}/actu'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nombre': txtnombre.text,
          'descripcion': txtdesc.text,
          'fecha': txtfecha.text,
          'hora': txthora.text,
          'dosis': txtdosis.text,
          'frecuencia': txtfrecu.text,
          'id_usuario': int.parse(txtid_usuario.text),
        }),
      );

      if (response.statusCode == 200) {
        print('Medicamento actualizada correctamente');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Listmedicamentos()),
        );
      } else {
        print('Error al actualizar el medicamento: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Medicamento"),
        ),
        body: Container( // Agregamos un Container para definir el fondo
          color: Color(0xFFF5F5DC),
          width: 1100, // Opcional
          height: 1000,// Código de color beige
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nombre:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.nombre),
                const SizedBox(height: 10),
                const Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.descripcion),
                const SizedBox(height: 10),
                const Text(
                  "Fecha:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.fecha),
                const SizedBox(height: 10),
                const Text(
                  "Hora:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.hora),
                const SizedBox(height: 10),
                const Text(
                  "Dosis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.dosis),
                const SizedBox(height: 10),
                const Text(
                  "Frecuencia:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.medicamentos.frecuencia.toString()),
              ],
            ),
          ),
        )
    );
  }
}
