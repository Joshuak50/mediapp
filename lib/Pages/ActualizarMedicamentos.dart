import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediapp/Models/Medicamentos.dart';
import 'package:http/http.dart' as http;
import 'package:mediapp/Pages/ListMedicamentos.dart';
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
    txtfrecuDias = TextEditingController(text: widget.medicamentos.frecuenciaDias.toString());
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
          'frecuenciaDias': txtfrecuDias.text,
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
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    try{
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

                      int notificationID = 1;

// Si la fecha es válida, programar la notificación
                      if (scheduledDate != null) {
                        print("📅 Programando notificación para: $scheduledDate");

                        NotificationService.scheduleNotification(
                          "Recordatorio de medicamento",
                          "Es hora de tomar ${txtnombre.text}",
                          scheduledDate,
                          notificationID,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Notificación programada para ${txthora.text} el ${txtfecha.text}")),
                        );
                      } else {
                        print("⚠️ scheduledDate es nulo o inválido. No se programará la notificación.");
                      }

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
