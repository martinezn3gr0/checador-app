import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../models/checada_model.dart';
import '../../../models/session_model.dart';

class CheckInPage extends ConsumerStatefulWidget {
  final AppSession session;

  const CheckInPage({super.key, required this.session});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Registro de asistencia',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Antes de fichar, la app solicitará ubicación en primer plano. '
          'El backend validará que estés dentro del radio permitido.',
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(Icons.location_on_outlined, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Mapa de obra asignada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Placeholder para Google Maps: posición actual, centro de '
                  'obra y perímetro de 100m.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed:
              _isSubmitting ? null : () => _registerCheck(ChecadaType.entrada),
          icon: const Icon(Icons.login),
          label: const Text('Registrar entrada'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed:
              _isSubmitting ? null : () => _registerCheck(ChecadaType.salida),
          icon: const Icon(Icons.logout),
          label: const Text('Registrar salida'),
        ),
      ],
    );
  }

  Future<void> _registerCheck(ChecadaType type) async {
    setState(() => _isSubmitting = true);
    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      final checada = await ref.read(attendanceServiceProvider).registerCheck(
            employeeId: widget.session.userId,
            type: type,
            latitude: position.latitude,
            longitude: position.longitude,
          );

      if (!mounted) {
        return;
      }

      final distance = checada.distance == null
          ? ''
          : ' Distancia registrada: ${checada.distance!.toStringAsFixed(0)}m.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checada ${type.name} registrada.$distance'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
