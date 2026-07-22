import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../widgets/common/error_widget.dart';
import 'check_in_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class EmployeeShellPage extends ConsumerStatefulWidget {
  const EmployeeShellPage({super.key});

  @override
  ConsumerState<EmployeeShellPage> createState() => _EmployeeShellPageState();
}

class _EmployeeShellPageState extends ConsumerState<EmployeeShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider).valueOrNull;

    if (session == null) {
      return const Scaffold(
        body: ErrorDisplayWidget(message: 'Sesión no encontrada.'),
      );
    }

    final pages = [
      CheckInPage(session: session),
      HistoryPage(session: session),
      ProfilePage(session: session),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleado'),
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
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            label: 'Fichar',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
