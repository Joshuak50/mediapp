class Medicamentos {
  final int id;
  final String nombre;
  final String descripcion;
  final String hora;
  final String fecha;
  final String dosis;
  final int frecuencia;
  final int id_usuario; // Añadimos el campo id_usuario

  Medicamentos(this.id, this.nombre, this.descripcion, this.hora, this.fecha, this.dosis, this.frecuencia, this.id_usuario);

  Medicamentos.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nombre = json['nombre'],
        descripcion = json['descripcion'],
        hora = json['hora'],
        fecha = json['fecha'],
        dosis = json['dosis'],
        frecuencia = json['frecuencia'],
        id_usuario = json['id_usuario']; // Aseguramos que también se convierta

// Este getter ya no es necesario
// get id_usuario => null;
}