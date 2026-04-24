import 'package:go_router/go_router.dart';

import '../views/dashboard_view.dart';
import '../views/estadisticas_view.dart';
import '../views/establecimiento_form_view.dart';
import '../views/establecimientos_list_view.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/accidentes',
      name: 'accidentes',
      builder: (context, state) => const EstadisticasView(),
    ),
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    GoRoute(
      path: '/establecimientos/crear',
      name: 'establecimiento-create',
      builder: (context, state) => const EstablecimientoFormView(),
    ),
    GoRoute(
      path: '/establecimientos/:id/editar',
      name: 'establecimiento-edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return EstablecimientoFormView(id: id);
      },
    ),
  ],
);
