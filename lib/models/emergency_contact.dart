class EmergencyContact {
  final String nombre;
  final String telefono;
  final String direccion;
  final bool activo;
  final String tipoServicio;

  EmergencyContact({
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.activo,
    required this.tipoServicio,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      activo: map['activo'] ?? false,
      tipoServicio: map['tipoServicio'] ?? '',
    );
  }
}