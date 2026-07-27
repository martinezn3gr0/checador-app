import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';
import '../nav.dart';
import 'admin_login_screen.dart';
import 'new_company_screen.dart';

class AdminLandingScreen extends StatelessWidget {
  const AdminLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Navigator.canPop(context) ? const BackButton() : null),
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                            colors: [Color(0xFF3A2E07), Color(0xFF1A1503)]),
                        border:
                            Border.all(color: AppColors.amber.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.amber.withOpacity(0.35),
                              blurRadius: 36,
                              spreadRadius: 1)
                        ],
                      ),
                      child: const Icon(Icons.shield_moon_rounded,
                          size: 56, color: AppColors.amber),
                    ),
                    const SizedBox(height: 22),
                    GradientText('Checador Admin',
                        style: AppTheme.display(26),
                        gradient: AppGradients.admin),
                    const SizedBox(height: 10),
                    const Text('Panel de administración',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text(
                      'Registra tu empresa o inicia sesión si ya tienes una cuenta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 44),
                    NeonButton(
                      label: 'Nueva empresa',
                      icon: Icons.add_business_rounded,
                      gradient: AppGradients.admin,
                      onPressed: () => Navigator.of(context)
                          .push(fadeRoute(const NewCompanyScreen())),
                    ),
                    const SizedBox(height: 16),
                    NeonButton(
                      label: 'Empresa existente',
                      icon: Icons.login_rounded,
                      outlined: true,
                      onPressed: () => Navigator.of(context)
                          .push(fadeRoute(const AdminLoginScreen())),
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
