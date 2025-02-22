class Medicamentos {
  final int id;
  final String nombre;
  final String descripcion;
  final String hora;
  final String fecha;
  final String dosis; // Se queda como String si la API lo envía así
  final int frecuencia;
  final int frecuenciaDias;
  final int id_usuario;

  Medicamentos(
      this.id,
      this.nombre,
      this.descripcion,
      this.hora,
      this.fecha,
      this.dosis,
      this.frecuencia,
      this.frecuenciaDias,
      this.id_usuario,
      );

  factory Medicamentos.fromJson(Map<String, dynamic> json) {
    return Medicamentos(
      json['id'],
      json['nombre'],
      json['descripcion'],
      json['hora'],
      json['fecha'],
      json['dosis'], // Se deja como String
      int.tryParse(json['frecuencia'].toString()) ?? 0, // Convierte a int si es necesario
      int.tryParse(json['frecuenciaDias'].toString()) ?? 0, // Convierte a int si es necesario
      int.tryParse(json['id_usuario'].toString()) ?? 0, // Convierte a int si es necesario
    );
  }
}
