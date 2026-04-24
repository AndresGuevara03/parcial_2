import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_router.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de usar dotenv
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Carga las variables de entorno desde el archivo .env
    await dotenv.load(fileName: ".env");
    debugPrint('Configuración cargada correctamente:');
    debugPrint('Accidentes URL: ${dotenv.maybeGet('ACCIDENTES_API_URL')}');
    debugPrint('Parking URL: ${dotenv.maybeGet('PARKING_API_BASE_URL')}');
  } catch (e) {
    // Si no se encuentra el archivo .env o hay un error, se puede manejar aquí
    debugPrint('Error crítico cargando archivo .env: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parcial 2 - Flutter',
      debugShowCheckedModeBanner: false,
      // Aplicamos el tema azul premium definido en el proyecto
      theme: AppTheme.lightTheme,
      // Configuramos el router para manejar la navegación
      routerConfig: appRouter,
    );
  }
}
