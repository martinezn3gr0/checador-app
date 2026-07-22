import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../widgets/common/error_widget.dart';
import 'dashboard_page.dart';

class AdminShellPage extends ConsumerWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);

    return session.when(
      data: (value) {
        if (value == null) {
          return const ErrorDisplayWidget(message: 'Sesión no encontrada.');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel Admin'),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  await ref.read(currentSessionProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: AdminDashboardPage(session: value),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: ErrorDisplayWidget(message: error.toString()),
      ),
    );
  }
}
