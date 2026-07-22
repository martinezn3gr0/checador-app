import 'package:flutter/material.dart';

class ObrasPage extends StatelessWidget {
  const ObrasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obras')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Ubicación y radio operativo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada obra debe guardar latitud, longitud y un radio predeterminado '
            'de 100 metros. La validación final se realiza en backend por RPC.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.map_outlined, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    'Mapa de configuración',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Placeholder para Google Maps: seleccionar punto, mostrar '
                    'círculo de 100m y guardar con RPC admin_upsert_obra.',
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Radio: 100m')),
                      Chip(label: Text('Permisos foreground')),
                      Chip(label: Text('Haversine en backend')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pendiente conectar Google Maps + RPC.'),
                ),
              );
            },
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Nueva obra'),
          ),
        ],
      ),
    );
  }
}
