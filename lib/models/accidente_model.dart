class Accidente {
  const Accidente({
    required this.claseDeAccidente,
    required this.gravedadDelAccidente,
    required this.barrioHecho,
    required this.dia,
  });

  final String claseDeAccidente;
  final String gravedadDelAccidente;
  final String barrioHecho;
  final String dia;

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      claseDeAccidente: (json['clase_de_accidente'] ?? '').toString().trim(),
      gravedadDelAccidente: (json['gravedad_del_accidente'] ?? '')
          .toString()
          .trim(),
      barrioHecho: (json['barrio_hecho'] ?? '').toString().trim(),
      dia: (json['dia'] ?? '').toString().trim(),
    );
  }
}
