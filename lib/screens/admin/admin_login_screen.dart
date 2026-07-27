import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';
import '../nav.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _empresa = TextEditingController(text: 'INST01');
  final _usuario = TextEditingController(text: 'martinez');
  final _pin = TextEditingController(text: '1987');
  bool _loading = false;

  @override
  void dispose() {
    _empresa.dispose();
    _usuario.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      if (SupabaseService.instance.isConnected) {
        final admin = await SupabaseService.instance.loginAdmin(
          empresaCodigo: _empresa.text.trim(),
          usuario: _usuario.text.trim(),
          pin: _pin.text.trim(),
        );
        if (!mounted) return;
        if (admin == null) {
          _info('Sin acceso a datos (revisa credenciales/RLS). Modo demo.');
          Navigator.of(context).push(fadeRoute(const AdminShell()));
        } else {
          Navigator.of(context).push(fadeRoute(AdminShell(session: admin)));
        }
      } else {
        Navigator.of(context).push(fadeRoute(const AdminShell()));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    GradientText('Checador Admin',
                        style: AppTheme.display(24),
                        gradient: AppGradients.admin),
                    const SizedBox(height: 30),
                    GlassCard(
                      glowColor: AppColors.amber,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          NeonField(
                              label: 'Código de empresa',
                              icon: Icons.apartment_rounded,
                              controller: _empresa),
                          const SizedBox(height: 16),
                          NeonField(
                              label: 'Usuario admin',
                              icon: Icons.person_rounded,
                              controller: _usuario),
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
                                color: AppColors.amber),
                          )
                        : NeonButton(
                            label: 'Entrar al panel',
                            icon: Icons.dashboard_rounded,
                            gradient: AppGradients.admin,
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
