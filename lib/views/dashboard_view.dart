import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/establecimiento_model.dart';
import '../services/api_service.dart';
import '../widgets/app_error_view.dart';
import '../widgets/module_card.dart';

import '../widgets/premium_background.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;
  String? _error;
  int _totalAccidentes = 0;
  int _totalEstablecimientos = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var accidentes = 0;
      var establecimientos = const <Establecimiento>[];
      String? partialError;

      try {
        accidentes = await ApiService.instance.fetchAccidentesCount().timeout(
          const Duration(seconds: 12),
          onTimeout: () => 0,
        );
      } catch (e) {
        debugPrint('Error obteniendo accidentes: $e');
        partialError =
            'No se pudo obtener el total de accidentes. Se mostraran valores parciales.';
      }

      try {
        establecimientos = await ApiService.instance
            .fetchEstablecimientos()
            .timeout(
              const Duration(seconds: 12),
              onTimeout: () => const <Establecimiento>[],
            );
      } catch (_) {
        partialError =
            'No se pudo obtener el total de establecimientos. Se mostraran valores parciales.';
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _totalAccidentes = accidentes;
        _totalEstablecimientos = establecimientos.length;
        _error = partialError;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No se pudieron cargar los datos del dashboard.';
        _totalAccidentes = 0;
        _totalEstablecimientos = 0;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null &&
        !_isLoading &&
        _totalAccidentes == 0 &&
        _totalEstablecimientos == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: AppErrorView(message: _error!, onRetry: _loadData),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
          children: <Widget>[
            Text(
              'Bienvenido de nuevo',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Parcial Flutter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Módulos principales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Skeletonizer(
              enabled: _isLoading,
              child: ModuleCard(
                title: 'Estadisticas de Accidentes',
                subtitle: 'Total cargados: $_totalAccidentes registros',
                icon: Icons.pie_chart_outline_rounded,
                onTap: () => context.pushNamed('accidentes'),
              ),
            ),
            const SizedBox(height: 16),
            Skeletonizer(
              enabled: _isLoading,
              child: ModuleCard(
                title: 'Gestion de Establecimientos',
                subtitle: 'Total registrados: $_totalEstablecimientos establecimientos',
                icon: Icons.storefront_rounded,
                onTap: () => context.pushNamed('establecimientos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
