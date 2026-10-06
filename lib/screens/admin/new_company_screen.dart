import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';
import '../nav.dart';
import 'admin_shell.dart';

class NewCompanyScreen extends StatelessWidget {
  const NewCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva empresa'),
        leading: const BackButton(),
      ),
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 30),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Datos de la empresa'),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        children: const [
                          NeonField(
                              label: 'Código de empresa *',
                              icon: Icons.tag_rounded),
                          SizedBox(height: 16),
                          NeonField(
                              label: 'Nombre de la empresa *',
                              icon: Icons.apartment_rounded),
                          SizedBox(height: 16),
                          NeonField(
                              label: 'RFC (opcional)',
                              icon: Icons.description_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    _sectionTitle('Administrador inicial'),
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        children: const [
                          NeonField(
                              label: 'Nombre del admin *',
                              icon: Icons.person_rounded),
                          SizedBox(height: 16),
                          NeonField(
                              label: 'Usuario *',
                              icon: Icons.account_circle_rounded),
                          SizedBox(height: 16),
                          NeonField(
                              label: 'PIN *',
                              icon: Icons.lock_rounded,
                              obscure: true,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    NeonButton(
                      label: 'Crear empresa y entrar',
                      icon: Icons.rocket_launch_rounded,
                      gradient: AppGradients.admin,
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          fadeRoute(const AdminShell()),
                          (r) => r.isFirst),
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

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(width: 4, height: 18, color: AppColors.amber),
          const SizedBox(width: 10),
          Text(t,
              style: const TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ],
      );
}
