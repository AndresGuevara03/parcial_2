import 'dart:isolate';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../isolates/accidents_isolate.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_error_view.dart';

import '../widgets/premium_background.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({super.key});

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await ApiService.instance.fetchAccidentes().timeout(
        const Duration(seconds: 15),
      );

      late final Map<String, dynamic> result;
      try {
        result = await Isolate.run<Map<String, dynamic>>(
          () => calculateAccidentStats(records),
        );
      } catch (_) {
        // Fallback local si el envío al isolate falla por serialización.
        result = calculateAccidentStats(records);
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _stats = result;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Ocurrio un error al generar las estadisticas.';
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
    final body = _error != null
        ? AppErrorView(message: _error!, onRetry: _loadStats)
        : Skeletonizer(
            enabled: _isLoading,
            child: _isLoading || _stats == null
                ? _buildLoadingState()
                : _buildCharts(),
          );

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
        title: const Text('Estadisticas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadStats,
          ),
        ],
      ),
      body: PremiumBackground(child: body),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
      children: const <Widget>[
        _ChartCardPlaceholder(title: 'Distribucion por clase de accidente'),
        SizedBox(height: 12),
        _ChartCardPlaceholder(title: 'Distribucion por gravedad'),
        SizedBox(height: 12),
        _ChartCardPlaceholder(title: 'Top barrios'),
        SizedBox(height: 12),
        _ChartCardPlaceholder(title: 'Distribucion por dia'),
      ],
    );
  }

  Widget _buildCharts() {
    final claseAccidente = Map<String, int>.from(
      _stats!['claseAccidente'] as Map,
    );
    final gravedad = Map<String, int>.from(_stats!['gravedad'] as Map);
    final topBarrios = Map<String, int>.from(_stats!['topBarrios'] as Map);
    final diaSemana = Map<String, int>.from(_stats!['diaSemana'] as Map);
    final total = claseAccidente.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
      children: <Widget>[
        _buildSummaryCard(total),
        const SizedBox(height: 12),
        _buildPieCard('Distribucion por clase de accidente', claseAccidente),
        const SizedBox(height: 12),
        _buildPieCard('Distribucion por gravedad', gravedad),
        const SizedBox(height: 12),
        _buildBarCard(
          'Top 5 barrios con mas accidentes',
          topBarrios,
          shortLabel: _shortBarrio,
        ),
        const SizedBox(height: 12),
        _buildBarCard(
          'Distribucion por dia de la semana',
          diaSemana,
          shortLabel: _shortDay,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: <Color>[AppTheme.primaryColor, AppTheme.primaryLight],
                ),
              ),
              child: const Icon(Icons.insights, color: Color(0xFF051015)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Resumen general',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total accidentes analizados',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieCard(String title, Map<String, int> data) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    final colors = <Color>[
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.primaryLight,
      const Color(0xFF5C6BC0), // Indigo
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardTheme.color,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : const Color(0xFFE0E6EA),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: data.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final value = item.value.toDouble();
                        final pct = total == 0
                            ? 0
                            : ((item.value / total) * 100).round();
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: value,
                          radius: 35,
                          title: '$pct%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: data.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final color = colors[index % colors.length];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.key}: ${item.value}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarCard(
    String title,
    Map<String, int> data, {
    required String Function(String) shortLabel,
  }) {
    final entries = data.entries.toList(growable: false);
    final maxY = entries.isEmpty
        ? 10.0
        : (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2);
    final chartWidth = entries.length * 75.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardTheme.color,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : const Color(0xFFE0E6EA),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth < 320 ? 320 : chartWidth,
                height: 320,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => AppTheme.surfaceColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = entries[group.x.toInt()].key;
                          return BarTooltipItem(
                            '$label\n${rod.toY.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 34,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= entries.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              space: 10,
                              angle: -0.8, // Radianes (~45 grados)
                              child: Text(
                                shortLabel(entries[index].key),
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: entries.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      
                      // Rotación de colores Neon
                      final colors = [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                        AppTheme.accentColor,
                        AppTheme.primaryLight,
                      ];
                      final color = colors[i % colors.length];

                      return BarChartGroupData(
                        x: i,
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: item.value.toDouble(),
                            color: color,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortBarrio(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) {
      return '-';
    }
    if (cleaned.length <= 8) {
      return cleaned;
    }
    return '${cleaned.substring(0, 8)}...';
  }

  String _shortDay(String value) {
    switch (value.toLowerCase()) {
      case 'lunes':
        return 'lun';
      case 'martes':
        return 'mar';
      case 'miercoles':
        return 'mie';
      case 'jueves':
        return 'jue';
      case 'viernes':
        return 'vie';
      case 'sabado':
        return 'sab';
      case 'domingo':
        return 'dom';
      default:
        return value;
    }
  }
}

class _ChartCardPlaceholder extends StatelessWidget {
  const _ChartCardPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title),
            const SizedBox(height: 12),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
