import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/session_model.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';

class StartupPage extends ConsumerWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentSessionProvider, (previous, next) {
      next.whenOrNull(
        data: (session) {
          final route = switch (session?.role) {
            UserRole.admin => AppRoutes.adminHome,
            UserRole.employee => AppRoutes.employeeHome,
            null => AppRoutes.login,
          };

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          });
        },
      );
    });

    final session = ref.watch(currentSessionProvider);

    return Scaffold(
      body: session.when(
        data: (_) => const LoadingWidget(message: 'Preparando sesión...'),
        loading: () =>
            const LoadingWidget(message: 'Validando sesión segura...'),
        error: (error, _) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.read(currentSessionProvider.notifier).restore(),
        ),
      ),
    );
  }
}
