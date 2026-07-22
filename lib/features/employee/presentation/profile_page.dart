import 'package:flutter/material.dart';

import '../../../models/session_model.dart';

class ProfilePage extends StatelessWidget {
  final AppSession session;

  const ProfilePage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Perfil',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileRow(
                  label: 'Código',
                  value: session.userCode,
                  icon: Icons.badge_outlined,
                ),
                const Divider(height: 28),
                const _ProfileRow(
                  label: 'Puesto',
                  value: 'Pendiente de cargar desde RPC employee_profile',
                  icon: Icons.work_outline,
                ),
                const Divider(height: 28),
                const _ProfileRow(
                  label: 'Obra asignada',
                  value: 'Pendiente de relación employee -> obra',
                  icon: Icons.location_city_outlined,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
