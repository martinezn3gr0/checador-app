import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/app_providers.dart';
import '../../../models/checada_model.dart';
import '../../../models/session_model.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';

final employeeHistoryProvider =
    FutureProvider.family<List<Checada>, String>((ref, employeeId) {
  return ref
      .watch(attendanceServiceProvider)
      .fetchHistory(employeeId: employeeId);
});

class HistoryPage extends ConsumerWidget {
  final AppSession session;

  const HistoryPage({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(employeeHistoryProvider(session.userId));

    return history.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Aún no hay checadas registradas.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final checada = items[index];
            final formatter = DateFormat('dd/MM/yyyy HH:mm');
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: Icon(
                checada.type == ChecadaType.entrada
                    ? Icons.login
                    : Icons.logout,
              ),
              title: Text(checada.type.name.toUpperCase()),
              subtitle: Text(
                '${formatter.format(checada.timestamp)}\n'
                'Estatus: ${checada.status.name}',
              ),
              isThreeLine: true,
              trailing: checada.distance == null
                  ? null
                  : Text('${checada.distance!.toStringAsFixed(0)}m'),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
      loading: () => const LoadingWidget(useShimmer: true),
      error: (error, _) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(employeeHistoryProvider(session.userId)),
      ),
    );
  }
}
