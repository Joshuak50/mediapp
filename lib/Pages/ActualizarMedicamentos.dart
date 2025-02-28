import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediapp/Models/Medicamentos.dart';
import 'package:http/http.dart' as http;
import 'package:mediapp/Pages/ListMedicamentos.dart';
import 'package:mediapp/Pages/NuevoMedicamento.dart';
import 'package:timezone/timezone.dart' as tz;
import '../Utilerias/Ambiente.dart';
import '../Widgets/notification_services.dart';

class Actualizarmedicamentos extends StatefulWidget {
  final Medicamentos medicamentos;
  const Actualizarmedicamentos({super.key, required this.medicamentos});

  @override
  State<Actualizarmedicamentos> createState() => _ActualizarmedicamentosState();
}

class _ActualizarmedicamentosState extends State<Actualizarmedicamentos> {
  late TextEditingController txtid;
  late TextEditingController txtnombre;
  late TextEditingController txtdesc;
  late TextEditingController txtfecha;
  late TextEditingController txthora;
  late TextEditingController txtdosis;
  late TextEditingController txtfrecu;
  late TextEditingController txtfrecuDias;
  late TextEditingController txtalergia;
  late TextEditingController txtOtraAlergia;
  late TextEditingController txtid_usuario;

  List<String> alergia = ["Paracetamol", "Penicilina", "Digoxina", "Amoxicilina"];
  String? alergiaSeleccionada;

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
    txtfrecuDias = TextEditingController(text: widget.medicamentos.frecuenciaDias.toString());
    txtalergia = TextEditingController(text: widget.medicamentos.alergia);
    txtOtraAlergia = TextEditingController(text: widget.medicamentos.otraAlergia);
    txtid_usuario = TextEditingController(text: widget.medicamentos.id_usuario.toString());
    alergiaSeleccionada = txtalergia.text;
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
          'frecuenciaDias': txtfrecuDias.text,
          'alergia': txtalergia.text,
          'otraAlergia': txtOtraAlergia.text,
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
          title: const Text("Actualizar Medicamento"),
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
                    labelText: "Nombre",
                  ),
                ),
                TextFormField(
                  controller: txtdesc,
                  decoration: const InputDecoration(
                    labelText: "Descripcion",
                  ),
                ),
                TextFormField(
                  controller: txtfecha,
                  decoration: const InputDecoration(
                    labelText: "Fecha",
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
                    labelText: "Hora",
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
                    labelText: "Dosis",
                  ),
                ),
                TextFormField(
                  controller: txtfrecu,
                  keyboardType: TextInputType.number, // Solo permite teclado numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Filtra solo números
                  ],
                  decoration: const InputDecoration(
                    labelText: "Frecuencia",
                  ),
                ),
                TextFormField(
                  controller: txtfrecuDias,
                  keyboardType: TextInputType.number, // Solo permite teclado numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Filtra solo números
                  ],
                  decoration: const InputDecoration(
                    labelText: "Dias",
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Alergias",
                  ),
                  value: alergia.contains(alergiaSeleccionada) ? alergiaSeleccionada : "Otros", // Si no está en la lista, forzar "Otros"
                  onChanged: (String? newValue) {
                    setState(() {
                      alergiaSeleccionada = newValue;
                      if (newValue != "Otros") {
                        txtOtraAlergia.text = ""; // Limpia el campo si no es "Otros"
                      }
                    });
                  },
                  items: alergia.map((String alergia) {
                    return DropdownMenuItem<String>(
                      value: alergia,
                      child: Text(alergia),
                    );
                  }).toList()
                    ..add(const DropdownMenuItem<String>(
                      value: "Otros",
                      child: Text("Otros"),
                    )),
                ),
                if (alergiaSeleccionada == "Otros")
                  TextFormField(
                    controller: txtOtraAlergia,
                    decoration: const InputDecoration(
                      labelText: "Especificar otra alergia",
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    try {
                      // 1️⃣ Eliminar notificaciones existentes
                      int medicamentoId = widget.medicamentos.id;
                      List<int> notificationIds = await obtenerIdsNotificacion(medicamentoId);
                      print("🔍 IDs de notificaciones a eliminar: $notificationIds");

                      if (notificationIds.isNotEmpty) {
                        for (int id in notificationIds) {
                          await NotificationService.cancelNotification(id);
                          print("❌ Notificación con ID $id cancelada");
                        }
                      } else {
                        print("⚠️ No hay notificaciones asociadas a este medicamento para eliminar.");
                      }

                      // 2️⃣ Programar nuevas notificaciones
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

                      List<int> newNotificationIds = [];
                      if (scheduledDate != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Notificación programada para ${txthora.text} el ${txtfecha.text}")),
                        );

                        int frecuencia = int.tryParse(txtfrecu.text) ?? 0;
                        int dias = int.tryParse(txtfrecuDias.text) ?? 0;

                        if (frecuencia > 0 && dias > 0) {
                          for (int d = 0; d < dias; d++) {
                            for (int i = 0; i < (24 ~/ frecuencia); i++) {
                              DateTime newScheduledDate = scheduledDate.add(Duration(days: d, hours: frecuencia * i));
                              int notificationId = (scheduledDate.millisecondsSinceEpoch ~/ 1000) % 10000 + (d * 100) + i;
                              newNotificationIds.add(notificationId);
                              print("📅 Programando notificación para: $newScheduledDate con ID: $notificationId");

                              NotificationService.scheduleNotification(
                                "Recordatorio de medicamento",
                                "Es hora de tomar ${txtnombre.text}",
                                newScheduledDate,
                                notificationId,
                              );
                            }
                          }
                        }
                      } else {
                        print("⚠️ scheduledDate es nulo o inválido. No se programará la notificación.");
                      }

                      // 3️⃣ Actualizar el medicamento en la base de datos
                      final response = await http.put(
                        Uri.parse('${Ambiente.urlServe}/api/categoria/$medicamentoId/actu'),
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
                          'frecuenciaDias': txtfrecuDias.text,
                          'alergia': alergiaSeleccionada,
                          'otraAlergia': txtOtraAlergia.text,
                          'id_usuario': int.parse(txtid_usuario.text),
                        }),
                      );

                      if (response.statusCode == 200) {
                        print('Medicamento actualizado correctamente');

                        // 4️⃣ Guardar los nuevos IDs de notificación
                        await guardarIdsNotificacion(medicamentoId, newNotificationIds);

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
                  },
                  child: const Text("Actualizar"),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        )
    );
  }
}
