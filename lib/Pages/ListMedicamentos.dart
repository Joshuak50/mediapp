import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mediapp/Models/Medicamentos.dart';
import 'package:mediapp/Pages/ActualizarMedicamentos.dart';
import 'package:mediapp/Pages/NuevoMedicamento.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediapp/Widgets/notification_services.dart';
import '../Utilerias/Ambiente.dart';
import '../Widgets/custom_drawer.dart';
import 'DatosMedicamento.dart';

class Listmedicamentos extends StatefulWidget {
  const Listmedicamentos({super.key});

  @override
  State<Listmedicamentos> createState() => _ListmedicamentosState();
}

class _ListmedicamentosState extends State<Listmedicamentos> {
  List<Medicamentos> medicamentos = [];

  String? nombreUsuario;
  String? fotoPerfil;

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

  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_usuario');  // Recupera el id_usuario guardado
  }

  void fnObtenerCategorias() async {
    // Obtener el idUsuario desde SharedPreferences
    final idUsuario = await obtenerIdUsuario();
    if (idUsuario == null) {
      print('No se encontró el ID del usuario');
      return;  // Terminar la función si no se encuentra el ID
    } else {
      print('ID del usuario recuperado: $idUsuario');
    }
    try {
      // Realizar la solicitud HTTP pasando el idUsuario como parámetro en lugar de token
      final response = await http.get(
        Uri.parse('${Ambiente.urlServe}/api/categorias?user_id=$idUsuario'),  // Pasar el idUsuario como parámetro de consulta
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          // No es necesario el token aquí si estás usando el idUsuario directamente
        },
      );
      // Manejar la respuesta
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('data')) {
          Iterable mapCategorias = responseBody['data'];
          medicamentos = List<Medicamentos>.from(
            mapCategorias.map((model) => Medicamentos.fromJson(model)),
          );

          print('Medicamentos cargados: ${medicamentos.length}');

          setState(() {});
        } else {
          print('Error: La clave "data" no está en la respuesta');
        }
      } else {
        print('Error al obtener los medicamentos: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<double> _fnObtenerMontoTotal(int medicamentoId) async {
    final idUsuario = await obtenerIdUsuario(); // Obtener el ID del usuario
    if (idUsuario == null) {
      print("No se encontró el ID del usuario");
      return 0.0;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${Ambiente.urlServe}/api/subcategoria/monto?user_id=$idUsuario&categoria_id=$medicamentoId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        // Convertir el monto a double
        var totalMonto = responseBody['data']['total_monto'];
        if (totalMonto is String) {
          return double.tryParse(totalMonto) ?? 0.0; // Convertir String a double
        } else if (totalMonto is num) {
          return totalMonto.toDouble(); // Asegurar que sea double
        } else {
          return 0.0;
        }
      } else {
        print("Error al obtener el monto total: ${response.statusCode}");
        return 0.0;
      }
    } catch (e) {
      print("Error: $e");
      return 0.0;
    }
  }

  Future<void> _fnEliminarMedicamento(int medicamentoId) async {
    try {
      List<int> notificationIds = await obtenerIdsNotificacion(medicamentoId);
      print("🔍 IDs de notificaciones a eliminar: $notificationIds");
      // 🔥 Cancelar solo las notificaciones asociadas a este medicamento
      if(notificationIds.isNotEmpty) {
        for (int id in notificationIds) {
          await NotificationService.cancelNotification(id);
          print("❌ Notificación con ID $id cancelada");
        }
      }else{
        print("⚠️ No hay notificaciones asociadas a este medicamento para eliminar.");
      }
      final response = await http.delete(
        Uri.parse('${Ambiente.urlServe}/api/categoria/$medicamentoId/borrar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Categoría eliminada correctamente');
        setState(() {
          medicamentos.removeWhere((medicamento) => medicamento.id == medicamentoId); // Remover localmente
        });
      } else {
        print('Error al eliminar la categoría: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _listViewMedicamentos() {
    return ListView.builder(
      itemCount: medicamentos.length,
      itemBuilder: (context, index) {
        final medicamento = medicamentos[index]; // Referencia a la categoría actual

        return FutureBuilder<double>(
          future: _fnObtenerMontoTotal(medicamento.id),
          builder: (context, snapshot) {
            String montoText = "Cargando...";
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                montoText = "Hora: ${medicamento.hora}";
              } else {
                montoText = "Error al cargar monto";
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(medicamento.nombre),
                subtitle: Text(montoText),
                // subtitle: Text(montoText), // Mostrar el monto total aquí
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Actualizarmedicamentos(medicamentos: medicamento),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _fnEliminarMedicamento(medicamento.id); // Método para eliminar categoría
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Datosmedicamento(medicamentos: medicamento),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    obtenerDatosUsuario();
    obtenerIdUsuario().then((idUsuario) {
      if (idUsuario != null) {
        fnObtenerCategorias();

      } else {
        print('No se encontró el ID del usuario');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicamentos"),
      ),
      drawer: CustomDrawer(),
      body: Container( // Agregamos un Container para definir el fondo
          color: Color(0xFFF5F5DC),
          width: 1100,
          height: 1000,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 1000,
                  child: medicamentos.isNotEmpty
                      ? _listViewMedicamentos()
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Nuevomedicamento(),
            ),
          ).then((value) {
            if (value == true) {
              fnObtenerCategorias(); // Refrescar la lista de categorías si se creó una nueva.
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
