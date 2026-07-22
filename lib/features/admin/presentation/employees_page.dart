import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../models/employee_model.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';

final employeesProvider =
    FutureProvider.family<List<Employee>, EmployeesQuery>((ref, query) {
  return ref.watch(employeeServiceProvider).fetchEmployees(
        companyId: query.companyId,
        isActive: query.isActive,
        obraId: query.obraId,
      );
});

class EmployeesQuery {
  final String companyId;
  final bool? isActive;
  final String? obraId;

  const EmployeesQuery({
    required this.companyId,
    this.isActive,
    this.obraId,
  });

  factory EmployeesQuery.fromFilters(
    String companyId,
    Map<String, dynamic> filters,
  ) {
    return EmployeesQuery(
      companyId: companyId,
      isActive: filters['is_active'] as bool?,
      obraId: filters['obra_id'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeesQuery &&
        other.companyId == companyId &&
        other.isActive == isActive &&
        other.obraId == obraId;
  }

  @override
  int get hashCode => Object.hash(companyId, isActive, obraId);
}

class EmployeesPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> filters;

  const EmployeesPage({super.key, this.filters = const {}});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider).valueOrNull;
    final companyId = session?.companyId;

    if (companyId == null || companyId.isEmpty) {
      return const Scaffold(
        body: ErrorDisplayWidget(
          message: 'No se encontró empresa asociada a la sesión.',
        ),
      );
    }

    final query = EmployeesQuery.fromFilters(companyId, widget.filters);
    final employees = ref.watch(employeesProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: employees.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final employee = items[index];
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: Colors.white,
              leading: CircleAvatar(child: Text(_initials(employee.fullName))),
              title: Text(employee.fullName),
              subtitle: Text(
                '${employee.code} · ${employee.position}\n'
                'Obra asignada: ${employee.obraName ?? 'Sin asignar'}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Regenerar PIN',
                onPressed: () => _regeneratePin(employee.id),
                icon: const Icon(Icons.key_outlined),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        ),
        loading: () => const LoadingWidget(useShimmer: true),
        error: (error, _) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(employeesProvider(query)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEmployeeSheet(companyId),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo'),
      ),
    );
  }

  Future<void> _showCreateEmployeeSheet(String companyId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registrar empleado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Puesto'),
                  validator: _required,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isCreating ? null : () => _createEmployee(companyId),
                  child: Text(_isCreating ? 'Guardando...' : 'Guardar empleado'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createEmployee(String companyId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);
    try {
      await ref.read(employeeServiceProvider).createEmployee(
            companyId: companyId,
            fullName: _nameController.text,
            email: _emailController.text,
            position: _positionController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        _nameController.clear();
        _emailController.clear();
        _positionController.clear();
        ref.invalidate(employeesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empleado creado. Credenciales enviadas por correo.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _regeneratePin(String employeeId) async {
    final session = ref.read(currentSessionProvider).valueOrNull;
    if (session == null) {
      return;
    }

    await ref.read(employeeServiceProvider).regeneratePin(
          employeeId: employeeId,
          requestedByUserId: session.userId,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN regenerado y enviado por correo.')),
      );
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido';
    }

    return null;
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed.substring(0, 1).toUpperCase();
  }
}
