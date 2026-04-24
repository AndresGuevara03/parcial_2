class Establecimiento {
  const Establecimiento({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.logo,
  });

  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String logo;

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      id: _asInt(json['id']),
      nombre: (json['nombre'] ?? '').toString().trim(),
      nit: (json['nit'] ?? '').toString().trim(),
      direccion: (json['direccion'] ?? '').toString().trim(),
      telefono: (json['telefono'] ?? '').toString().trim(),
      logo: (json['logo'] ?? json['logo_url'] ?? '').toString().trim(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString()) ?? 0;
  }
}
