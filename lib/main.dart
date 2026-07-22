import 'package:flutter/material.dart';

import 'models/checada_model.dart';

void main() {
  runApp(const CheckadorExpressApp());
}

class CheckadorExpressApp extends StatelessWidget {
  const CheckadorExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CheckInScreen(),
    );
  }
}

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final List<Checada> _checadas = <Checada>[];

  void _registrar(CheckadaType type) {
    final now = DateTime.now();
    setState(() {
      _checadas.insert(
        0,
        Checada(
          id: now.microsecondsSinceEpoch.toString(),
          employeeId: 'emp-001',
          obraId: 'obra-001',
          type: type,
          status: CheckadaStatus.verified,
          timestamp: now,
          biometricVerified: false,
          createdAt: now,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${type == CheckadaType.entrada ? 'Entrada' : 'Salida'} registrada',
        ),
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checador Express'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('btn-entrada'),
                    onPressed: () => _registrar(CheckadaType.entrada),
                    icon: const Icon(Icons.login),
                    label: const Text('Entrada'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    key: const Key('btn-salida'),
                    onPressed: () => _registrar(CheckadaType.salida),
                    icon: const Icon(Icons.logout),
                    label: const Text('Salida'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Registros de hoy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _checadas.isEmpty
                  ? const Center(child: Text('Sin registros aún'))
                  : ListView.separated(
                      itemCount: _checadas.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = _checadas[index];
                        final isEntrada = c.type == CheckadaType.entrada;
                        return ListTile(
                          leading: Icon(
                            isEntrada ? Icons.login : Icons.logout,
                            color: isEntrada ? Colors.green : Colors.orange,
                          ),
                          title: Text(isEntrada ? 'Entrada' : 'Salida'),
                          subtitle: Text('Estado: ${c.status.name}'),
                          trailing: Text(_formatTime(c.timestamp)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
