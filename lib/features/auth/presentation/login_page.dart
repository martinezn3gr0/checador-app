import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../models/session_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyCodeController = TextEditingController();
  final _userCodeController = TextEditingController();
  final _pinController = TextEditingController();
  UserRole _role =
      AppConfig.flavor == AppFlavor.admin ? UserRole.admin : UserRole.employee;

  @override
  void dispose() {
    _companyCodeController.dispose();
    _userCodeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentSessionProvider, (previous, next) {
      next.whenOrNull(
        data: (session) {
          if (session == null) {
            return;
          }

          final route = session.role == UserRole.admin
              ? AppRoutes.adminHome
              : AppRoutes.employeeHome;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          });
        },
      );
    });

    final sessionState = ref.watch(currentSessionProvider);
    final flavor = AppConfig.flavor;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.fact_check, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Checador Express',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acceso por empresa, código y PIN seguro',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _companyCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de empresa',
                        prefixIcon: Icon(Icons.business),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _userCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de usuario',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: _required,
                    ),
                    if (flavor == AppFlavor.unified) ...[
                      const SizedBox(height: 16),
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(
                            value: UserRole.employee,
                            label: Text('Empleado'),
                            icon: Icon(Icons.person_outline),
                          ),
                          ButtonSegment(
                            value: UserRole.admin,
                            label: Text('Admin'),
                            icon: Icon(Icons.admin_panel_settings_outlined),
                          ),
                        ],
                        selected: {_role},
                        onSelectionChanged: (selection) {
                          setState(() => _role = selection.first);
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: sessionState.isLoading ? null : _submit,
                      icon: sessionState.isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: const Text('Iniciar sesión'),
                    ),
                    sessionState.when(
                      data: (_) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(currentSessionProvider.notifier).login(
          companyCode: _companyCodeController.text,
          userCode: _userCodeController.text,
          pin: _pinController.text,
          role: _role,
        );
  }
}
