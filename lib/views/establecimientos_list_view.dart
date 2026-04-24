import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/establecimiento_model.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_error_view.dart';

import '../widgets/premium_background.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() =>
      _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  bool _isLoading = true;
  String? _error;
  List<Establecimiento> _items = <Establecimiento>[];

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
      final list = await ApiService.instance.fetchEstablecimientos();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = list;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No fue posible cargar los establecimientos.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreate() async {
    final changed = await context.pushNamed<bool>('establecimiento-create');
    if (changed == true) {
      await _loadData();
    }
  }

  Future<void> _openEdit(int id) async {
    final changed = await context.pushNamed<bool>(
      'establecimiento-edit',
      pathParameters: <String, String>{'id': '$id'},
    );
    if (changed == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _error != null
        ? AppErrorView(message: _error!, onRetry: _loadData)
        : Skeletonizer(enabled: _isLoading, child: _buildList());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            context.goNamed('dashboard');
          },
        ),
        title: const Text('Establecimientos'),
      ),
      body: PremiumBackground(
        child: RefreshIndicator(
          displacement: 100,
          onRefresh: _loadData,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: body,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    final data = _isLoading
        ? List<Establecimiento>.generate(
            6,
            (index) => Establecimiento(
              id: 0,
              nombre: 'Establecimiento Demo',
              nit: '90000000$index',
              direccion: 'Direccion de ejemplo',
              telefono: '3000000000',
              logo: '',
            ),
          )
        : _items;

    if (!_isLoading && data.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        children: const <Widget>[
          Icon(Icons.storefront_outlined, size: 52),
          SizedBox(height: 8),
          Center(child: Text('No hay establecimientos registrados.')),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final hasRemoteLogo = item.logo.startsWith('http');

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardTheme.color,
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE0E6EA),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: _isLoading ? null : () => _openEdit(item.id),
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: <Color>[AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: hasRemoteLogo
                    ? DecorationImage(
                        image: NetworkImage(item.logo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasRemoteLogo
                  ? null
                  : Icon(
                      Icons.business_rounded, 
                      color: isDark ? AppTheme.primaryLight : const Color(0xFF051015),
                    ),
            ),
            title: Text(
              item.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'NIT: ${item.nit}\n${item.direccion}',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ),
        );
      },
    );
  }
}
