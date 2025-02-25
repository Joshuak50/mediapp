import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mediapp/Pages/ListMedicamentos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utilerias/Ambiente.dart';
import '../Widgets/notification_services.dart';
import 'package:timezone/timezone.dart' as tz;


class Nuevomedicamento extends StatefulWidget {
  const Nuevomedicamento({super.key});

  @override
  State<Nuevomedicamento> createState() => _NuevomedicamentoState();
}

Future<int?> obtenerIdUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id_usuario');  // Asegúrate de que el ID del usuario esté guardado bajo esta clave
}

Future<void> guardarIdsNotificacion(int medicamentoId, List<int> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(medicamentoId.toString(), ids.map((e) => e.toString()).toList());
}

Future<void> debugSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  print("🔍 Contenido actual de SharedPreferences:");
  prefs.getKeys().forEach((key) {
    print("$key: ${prefs.getStringList(key)}");
  });
}

Future<List<int>> obtenerIdsNotificacion(int medicamentoId) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? idsStringList = prefs.getStringList(medicamentoId.toString());

  if (idsStringList != null) {
    return idsStringList.map(int.parse).toList();
  } else {
    return [];
  }
}

class _NuevomedicamentoState extends State<Nuevomedicamento> {
  TextEditingController txtnombre = TextEditingController();
  TextEditingController txtdesc = TextEditingController();
  TextEditingController txtfecha = TextEditingController();
  TextEditingController txthora = TextEditingController();
  TextEditingController txtdosis = TextEditingController();
  TextEditingController txtfrecu = TextEditingController();
  TextEditingController txtfrecuDias = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nuevo Medicamento"),
        ),
        body: Container( // Agregamos un Container para definir el fondo
          color: Color(0xFFF5F5DC), // Código de color beige
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: txtnombre,
                  decoration: const InputDecoration(
                    labelText: "Nombre del medicamento",
                  ),
                ),
                TextFormField(
                  controller: txtdesc,
                  decoration: const InputDecoration(
                    labelText: "Descripcion del medicamento",
                  ),
                ),
                TextFormField(
                  controller: txtfecha,
                  decoration: const InputDecoration(
                    labelText: "Fecha del medicamento",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        txtfecha.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },

                ),
                TextFormField(
                  controller: txthora,
                  decoration: const InputDecoration(
                    labelText: "Hora del medicamento",
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      DateTime now = DateTime.now();
                      DateTime scheduledDate = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      setState(() {
                        txthora.text = pickedTime.format(context);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Notificación programada para ${txthora.text}")),
                      );
                    }
                  },
                ),
                TextFormField(
                  controller: txtdosis,
                  decoration: const InputDecoration(
                    labelText: "Dosis del medicamento",
                  ),
                ),
                TextFormField(
                  controller: txtfrecu,
                  keyboardType: TextInputType.number, // Solo permite teclado numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Filtra solo números
                  ],
                  decoration: const InputDecoration(
                    labelText: "Frecuencia del medicamento",
                  ),
                ),
                TextFormField(
                  controller: txtfrecuDias,
                  keyboardType: TextInputType.number, // Solo permite teclado numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Filtra solo números
                  ],
                  decoration: const InputDecoration(
                    labelText: "por cuantos dias:",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (txtnombre.text.isEmpty) {
                      print('El nombre es obligatorio');
                      return;
                    }
                    try {
                      // Obtener el id_usuario automáticamente
                      int? id_usuario = await obtenerIdUsuario();
                      if (id_usuario == null) {

                        print('El id_usuario no está disponible');
                        return;
                      }

                      DateTime? scheduledDate;
                      if (txtfecha.text.isNotEmpty && txthora.text.isNotEmpty) {
                        List<String> fechaParts = txtfecha.text.split('-');
                        List<String> horaParts = txthora.text.replaceAll(RegExp(r'[^0-9:]'), '').split(':');

                        if (fechaParts.length == 3 && horaParts.length == 2) {
                          try {
                            DateTime localDateTime = DateTime(
                              int.parse(fechaParts[0].trim()), // Año
                              int.parse(fechaParts[1].trim()), // Mes
                              int.parse(fechaParts[2].trim()), // Día
                              int.parse(horaParts[0].trim()),  // Hora
                              int.parse(horaParts[1].trim()),  // Minuto
                            );

                            // Convertir a TZDateTime usando la zona horaria local
                            scheduledDate = tz.TZDateTime.from(localDateTime, tz.local);

                            // Si la hora ya pasó, mover al día siguiente
                            if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
                              scheduledDate = scheduledDate.add(const Duration(days: 1));
                              print("🔄 La hora ya pasó. Programando para el día siguiente: $scheduledDate");
                            }

                          } catch (e) {
                            print("❌ Error al convertir fecha y hora: $e");
                          }
                        }
                      }

                      List<int> notificationIds = [];

                      if (scheduledDate != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Notificación programada para ${txthora.text} el ${txtfecha.text}")),
                        );

                        int frecuencia = int.tryParse(txtfrecu.text) ?? 0;
                        int dias = int.tryParse(txtfrecuDias.text) ?? 0;

                        if (frecuencia > 0 && dias > 0) {
                          for (int d = 0; d < dias; d++) { // 🔥 Itera sobre los días
                            for (int i = 0; i < (24 ~/ frecuencia); i++) { // 🔥 Itera sobre las horas dentro de cada día
                              DateTime newScheduledDate = scheduledDate.add(Duration(days: d, hours: frecuencia * i));

                              int notificationId = (scheduledDate.millisecondsSinceEpoch ~/ 1000) % 10000 + (d * 100) + i;
                              notificationIds.add(notificationId);
                              print("📅 Programando notificación para: $newScheduledDate con ID: $notificationId");

                              NotificationService.scheduleNotification(
                                "Recordatorio de medicamento 2",
                                "Es hora de tomar ${txtnombre.text}",
                                newScheduledDate,
                                notificationId, // Pasar el ID único
                              );
                            }
                          }
                          print(notificationIds);
                        }
                      } else {
                        print("⚠️ scheduledDate es nulo o inválido. No se programará la notificación.");
                      }

                      final response = await http.post(
                        Uri.parse('${Ambiente.urlServe}/api/categoria/guardar'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, dynamic>{
                          'Nombre': txtnombre.text,
                          'Descripcion': txtdesc.text,
                          'Fecha': txtfecha.text,
                          'Hora': txthora.text,
                          'Dosis': txtdosis.text,
                          'Frecuencia': txtfrecu.text,
                          'FrecuenciaDias': txtfrecuDias.text,
                          'id_usuario': id_usuario,  // Usar el id_usuario obtenido
                        }),
                      );

                      if (response.statusCode == 200) {
                        print('Medicamento guardada correctamente');

                        print('Respuesta del servidor: ${response.body}'); // 👈 Debug

                        String responseBody = response.body.trim();

                        if (responseBody == "ok") {
                          print("El servidor devolvió 'ok', pero no un JSON con el ID.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Medicamento guardado, pero no se recibió un ID.")),
                          );

                        } else {
                          try {
                            final responseData = jsonDecode(responseBody);
                            int medicamentoId = responseData['id']; // Verifica que el servidor devuelva un 'id'

                            // Guardar notificaciones con el ID real
                            await guardarIdsNotificacion(medicamentoId, notificationIds);

                            Navigator.pop(context, true);
                          } catch (e) {
                            print('Error al procesar la respuesta del servidor: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error al procesar respuesta: ${response.body}")),
                            );
                          }
                        };
                      } else {
                        print('Error al guardar el medicamento: ${response.statusCode}');
                        print('Cuerpo de respuesta: ${response.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al guardar: ${response.body}")),
                        );
                      }
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Listmedicamentos()),
                    );
                  },
                  child: const Text("Guardar medicamento"),
                )
              ],
            ),
          ),
        )
    );
  }
}
