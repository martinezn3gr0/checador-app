import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/dashboard_metric_model.dart';
import '../../../models/session_model.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/metric_card.dart';

final adminMetricsProvider =
    FutureProvider.family<List<DashboardMetric>, String>((ref, companyId) {
  return ref
      .watch(employeeServiceProvider)
      .fetchDashboardMetrics(companyId: companyId);
});

class AdminDashboardPage extends ConsumerWidget {
  final AppSession session;

  const AdminDashboardPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(adminMetricsProvider(session.companyId ?? ''));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminMetricsProvider(session.companyId ?? ''));
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resumen operativo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca una tarjeta para ver el detalle filtrado.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          metrics.when(
            data: (items) => _MetricGrid(metrics: items),
            loading: () => const SizedBox(
              height: 360,
              child: LoadingWidget(useShimmer: true),
            ),
            error: (error, _) => SizedBox(
              height: 360,
              child: ErrorDisplayWidget(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(adminMetricsProvider(session.companyId ?? ''));
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.adminEmployees,
            ),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Registrar empleado'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.adminObras,
            ),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Gestionar obras y radios'),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<DashboardMetric> metrics;

  const _MetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final items = metrics.isEmpty ? _fallbackMetrics : metrics;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 3 : 1;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columns == 1 ? 2.3 : 1.25,
          ),
          itemBuilder: (context, index) {
            final metric = items[index];
            return MetricCard(
              title: metric.title,
              value: metric.value,
              subtitle: metric.subtitle,
              icon: _iconForMetric(metric.id),
              color: _colorForMetric(metric.id),
              onTap: metric.route.isEmpty
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        metric.route,
                        arguments: metric.filters,
                      ),
            );
          },
        );
      },
    );
  }

  static const List<DashboardMetric> _fallbackMetrics = [
    DashboardMetric(
      id: 'active-employees',
      title: 'Empleados activos',
      value: 0,
      route: AppRoutes.adminEmployees,
      filters: {'is_active': true},
    ),
    DashboardMetric(
      id: 'today-checks',
      title: 'Checadas hoy',
      value: 0,
      route: AppRoutes.adminEmployees,
      filters: {'date': 'today'},
    ),
    DashboardMetric(
      id: 'today-absences',
      title: 'Faltas hoy',
      value: 0,
      route: AppRoutes.adminEmployees,
      filters: {'attendance_status': 'absent', 'date': 'today'},
    ),
  ];

  static IconData _iconForMetric(String id) {
    switch (id) {
      case 'today-checks':
        return Icons.fact_check_outlined;
      case 'today-absences':
        return Icons.warning_amber_rounded;
      case 'active-employees':
      default:
        return Icons.groups_outlined;
    }
  }

  static Color _colorForMetric(String id) {
    switch (id) {
      case 'today-checks':
        return AppTheme.success;
      case 'today-absences':
        return AppTheme.warning;
      case 'active-employees':
      default:
        return AppTheme.primary;
    }
  }
}
