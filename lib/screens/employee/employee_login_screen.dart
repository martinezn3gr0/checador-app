import 'package:flutter/material.dart';

import '../../models/entities.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';
import '../nav.dart';
import 'employee_shell.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final _empresa = TextEditingController(text: 'INST01');
  final _empleado = TextEditingController(text: 'INST001');
  final _pin = TextEditingController(text: '1212');
  bool _loading = false;

  @override
  void dispose() {
    _empresa.dispose();
    _empleado.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      if (SupabaseService.instance.isConnected) {
        final empleado = await SupabaseService.instance.loginEmpleado(
          empresaCodigo: _empresa.text.trim(),
          empleadoCodigo: _empleado.text.trim(),
          pin: _pin.text.trim(),
        );
        if (!mounted) return;
        if (empleado == null) {
          // Either wrong credentials or RLS is blocking anon reads.
          _info('Sin acceso a datos (revisa credenciales/RLS). Modo demo.');
          Navigator.of(context).push(fadeRoute(const EmployeeShell()));
        } else {
          final obra = await SupabaseService.instance
              .obraForEmpleado(empleado.id, empleado.empresa.id);
          if (!mounted) return;
          Navigator.of(context).push(
              fadeRoute(EmployeeShell(empleado: empleado, obra: obra)));
        }
      } else {
        // Offline/demo mode.
        Navigator.of(context).push(fadeRoute(const EmployeeShell()));
      }
    } catch (e) {
      _error('No se pudo conectar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _error(String msg) => _snack(msg, AppColors.pink, Icons.error_outline);
  void _info(String msg) =>
      _snack(msg, AppColors.amber, Icons.info_outline_rounded);

  void _snack(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final connected = SupabaseService.instance.isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso empleado'),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const _PulseFingerprint(),
                    const SizedBox(height: 20),
                    GradientText('Checador Express',
                        style: AppTheme.display(24)),
                    const SizedBox(height: 8),
                    const Text('Ingresa con el código de tu empresa',
                        style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    _ConnBadge(connected: connected),
                    const SizedBox(height: 20),
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          NeonField(
                              label: 'Código de empresa',
                              icon: Icons.apartment_rounded,
                              controller: _empresa),
                          const SizedBox(height: 16),
                          NeonField(
                              label: 'Código de empleado',
                              icon: Icons.badge_rounded,
                              controller: _empleado),
                          const SizedBox(height: 16),
                          NeonField(
                              label: 'PIN',
                              icon: Icons.lock_rounded,
                              controller: _pin,
                              obscure: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                                color: AppColors.cyan),
                          )
                        : NeonButton(
                            label: 'Entrar',
                            icon: Icons.login_rounded,
                            onPressed: _login,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnBadge extends StatelessWidget {
  final bool connected;
  const _ConnBadge({required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.green : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(connected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: color, size: 16),
          const SizedBox(width: 6),
          Text(connected ? 'Conectado a Supabase' : 'Modo demo (local)',
              style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PulseFingerprint extends StatefulWidget {
  const _PulseFingerprint();

  @override
  State<_PulseFingerprint> createState() => _PulseFingerprintState();
}

class _PulseFingerprintState extends State<_PulseFingerprint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF13314F), Color(0xFF0A1730)],
          ),
          border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withOpacity(0.3 + _c.value * 0.4),
              blurRadius: 36,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.fingerprint, size: 56, color: AppColors.cyan),
      ),
    );
  }
}
