
Map<String, dynamic> calculateAccidentStats(
  List<Map<String, dynamic>> records,
) {
  final stopwatch = Stopwatch()..start();
  print('[Isolate] Iniciado — ${records.length} registros recibidos');

  final Map<String, int> claseAccidente = <String, int>{};
  final Map<String, int> gravedad = <String, int>{};
  final Map<String, int> barrios = <String, int>{};
  final Map<String, int> diaSemana = <String, int>{
    'lunes': 0,
    'martes': 0,
    'miercoles': 0,
    'jueves': 0,
    'viernes': 0,
    'sabado': 0,
    'domingo': 0,
  };

  for (final record in records) {
    final clase = _normalizeAccidentClass(record['clase_de_accidente']);
    final grav = _normalizeSeverity(record['gravedad_del_accidente']);
    final barrio = _normalizeText(
      record['barrio_hecho'],
      fallback: 'Sin barrio',
    );
    final dia = _normalizeDay(record['dia']);

    claseAccidente[clase] = (claseAccidente[clase] ?? 0) + 1;
    gravedad[grav] = (gravedad[grav] ?? 0) + 1;
    barrios[barrio] = (barrios[barrio] ?? 0) + 1;
    diaSemana[dia] = (diaSemana[dia] ?? 0) + 1;
  }

  final topBarriosEntries = barrios.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topBarrios = Map<String, int>.fromEntries(topBarriosEntries.take(5));

  stopwatch.stop();
  print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');

  return <String, dynamic>{
    'claseAccidente': claseAccidente,
    'gravedad': gravedad,
    'topBarrios': topBarrios,
    'diaSemana': diaSemana,
  };
}

String _normalizeAccidentClass(dynamic value) {
  final text = _normalizeText(value, fallback: 'Otros').toUpperCase();
  if (text.contains('CHOQUE')) {
    return 'Choque';
  }
  if (text.contains('ATROPELLO')) {
    return 'Atropello';
  }
  if (text.contains('VOLCAMIENTO')) {
    return 'Volcamiento';
  }
  return 'Otros';
}

String _normalizeSeverity(dynamic value) {
  final text = _normalizeText(value, fallback: 'Solo danos').toUpperCase();
  if (text.contains('MUERT')) {
    return 'Con muertos';
  }
  if (text.contains('HERID')) {
    return 'Con heridos';
  }
  return 'Solo danos';
}

String _normalizeDay(dynamic value) {
  final text = _normalizeText(value, fallback: '').toLowerCase();
  switch (text) {
    case 'lunes':
      return 'lunes';
    case 'martes':
      return 'martes';
    case 'miercoles':
    case 'miércoles':
      return 'miercoles';
    case 'jueves':
      return 'jueves';
    case 'viernes':
      return 'viernes';
    case 'sabado':
    case 'sábado':
      return 'sabado';
    case 'domingo':
      return 'domingo';
    default:
      return 'lunes';
  }
}

String _normalizeText(dynamic value, {required String fallback}) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    return fallback;
  }
  return text;
}
