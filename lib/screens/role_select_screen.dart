import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/futuristic.dart';
import 'employee/employee_login_screen.dart';
import 'admin/admin_landing_screen.dart';
import 'nav.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _HeroLogo(),
                    const SizedBox(height: 26),
                    GradientText('CHECADOR', style: AppTheme.display(38)),
                    GradientText('EXPRESS',
                        style: AppTheme.display(38),
                        gradient: AppGradients.admin),
                    const SizedBox(height: 12),
                    const Text(
                      'Control de asistencia laboral · multi-empresa',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    GlassCard(
                      glowColor: AppColors.cyan,
                      onTap: () => _go(context, const EmployeeLoginScreen()),
                      child: const _RoleRow(
                        icon: Icons.fingerprint,
                        color: AppColors.cyan,
                        title: 'Soy empleado',
                        subtitle: 'Registrar mis checadas',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      glowColor: AppColors.amber,
                      onTap: () => _go(context, const AdminLandingScreen()),
                      child: const _RoleRow(
                        icon: Icons.shield_moon_rounded,
                        color: AppColors.amber,
                        title: 'Soy administrador',
                        subtitle: 'Panel de gestión y reportes',
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text('v2.0 · edición futurista',
                        style: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.6),
                            fontSize: 12,
                            letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).push(fadeRoute(page));
  }
}

class _HeroLogo extends StatefulWidget {
  const _HeroLogo();

  @override
  State<_HeroLogo> createState() => _HeroLogoState();
}

class _HeroLogoState extends State<_HeroLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
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
      builder: (context, _) {
        final glow = 0.35 + _c.value * 0.35;
        return Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF13314F), Color(0xFF0A1730)],
            ),
            border: Border.all(color: AppColors.cyan.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withOpacity(glow),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.fingerprint, size: 64, color: AppColors.cyan),
        );
      },
    );
  }
}

class _RoleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _RoleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: AppColors.textMuted, size: 16),
      ],
    );
  }
}
