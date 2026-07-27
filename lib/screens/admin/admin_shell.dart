import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/entities.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';

class AdminShell extends StatefulWidget {
  final AdminSession? session;
  const AdminShell({super.key, this.session});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _section = 0; // 0 dashboard, 1 checadas, 2 faltas
  static const _titles = ['Inicio', 'Checadas de hoy', 'Faltas'];

  bool _loading = false;
  DashboardData? _data;
  List<Empleado> _faltas = [];

  String get _empresaNombre =>
      widget.session?.empresa.nombre ?? 'instalaciones jg';
  String get _adminNombre => widget.session?.nombre ?? 'jorge martinez';
  String get _empresaCodigo => widget.session?.empresa.codigo ?? 'INST01';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = widget.session;
    if (!SupabaseService.instance.isConnected || session == null) return;
    setState(() => _loading = true);
    final data = await SupabaseService.instance.dashboard(session.empresa.id);
    final faltas = await SupabaseService.instance.faltasHoy(session.empresa);
    if (mounted) {
      setState(() {
        _data = data;
        _faltas = faltas;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            Text(_titles[_section],
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(_empresaNombre,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.amber)),
        ],
      ),
      drawer: _AdminDrawer(
        selected: _section,
        adminNombre: _adminNombre,
        empresaLine: '$_empresaCodigo · $_empresaNombre',
        onSelect: (i) {
          Navigator.pop(context);
          setState(() => _section = i);
        },
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.amber))
              : switch (_section) {
                  1 => _ChecadasView(count: _data?.checadasHoy ?? 0),
                  2 => _FaltasView(faltas: _faltas),
                  _ => _DashboardView(data: _data),
                },
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final DashboardData? data;
  const _DashboardView({this.data});

  List<DashboardStat> get _stats {
    final d = data;
    if (d == null) return MockData.dashboardStats;
    return [
      DashboardStat('Empleados', '${d.empleados}', StatKind.people),
      DashboardStat('Asistencia', '${d.asistencia.toStringAsFixed(0)}%',
          StatKind.trend),
      DashboardStat('Entradas', '${d.entradas}', StatKind.checkIn),
      DashboardStat('Salidas', '${d.salidas}', StatKind.checkOut),
      DashboardStat('Faltas hoy', '${d.faltas}', StatKind.absent),
      DashboardStat('Obras activas', '${d.obrasActivas}', StatKind.works),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final d = data;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        Text('${now.day} ${months[now.month - 1]} ${now.year}',
            style: AppTheme.display(20)),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.5,
          children: _stats.map(_StatCard.new).toList(),
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado del día',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const _Pill(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.green,
                      label: 'Asistencia'),
                  const SizedBox(width: 10),
                  _Chip(
                      text: '${d?.presentes ?? 0} presentes',
                      color: AppColors.green),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const _Pill(
                      icon: Icons.cancel_rounded,
                      color: AppColors.pink,
                      label: 'Falta'),
                  const SizedBox(width: 10),
                  _Chip(
                      text: '${d?.faltas ?? 0} ausentes',
                      color: AppColors.pink),
                ],
              ),
              const SizedBox(height: 14),
              Text('${d?.checadasHoy ?? 0} checadas registradas hoy.',
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final DashboardStat stat;
  const _StatCard(this.stat);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: stat.kind.color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: stat.kind.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.kind.icon, color: stat.kind.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.value,
                  style: TextStyle(
                      color: stat.kind.color,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              Text(stat.label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _Pill({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

class _ChecadasView extends StatelessWidget {
  final int count;
  const _ChecadasView({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const _EmptyState(
          icon: Icons.fact_check_rounded, text: 'Sin checadas hoy');
    }
    return Center(
      child: GlassCard(
        glowColor: AppColors.green,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fact_check_rounded,
                color: AppColors.green, size: 40),
            const SizedBox(height: 12),
            Text('$count checadas registradas hoy',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FaltasView extends StatelessWidget {
  final List<Empleado> faltas;
  const _FaltasView({required this.faltas});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pink.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.pink, size: 18),
                const SizedBox(width: 8),
                Text('${faltas.length} faltas hoy',
                    style: const TextStyle(color: AppColors.pink)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (faltas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: _EmptyState(
                icon: Icons.emoji_events_rounded,
                text: 'Sin faltas registradas'),
          )
        else
          ...faltas.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  glowColor: AppColors.pink,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.pink.withOpacity(0.16),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.pink.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.person_off_rounded,
                            color: AppColors.pink),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.nombre,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            Text('${a.codigo} · ${a.departamento}',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                      const _Chip(text: 'Falta', color: AppColors.pink),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 14),
          Text(text, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final int selected;
  final String adminNombre;
  final String empresaLine;
  final ValueChanged<int> onSelect;
  const _AdminDrawer({
    required this.selected,
    required this.adminNombre,
    required this.empresaLine,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_rounded, 'Inicio', 0),
      (Icons.fact_check_rounded, 'Checadas de hoy', 1),
      (Icons.person_off_rounded, 'Faltas', 2),
    ];
    return Drawer(
      backgroundColor: AppColors.bg2,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.admin,
                    ),
                    child: const Icon(Icons.shield_moon_rounded,
                        color: Color(0xFF1A1503)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(adminNombre,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700)),
                        Text(empresaLine,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            ...items.map((it) {
              final active = it.$3 == selected;
              return ListTile(
                leading: Icon(it.$1,
                    color: active ? AppColors.cyan : AppColors.textMuted),
                title: Text(it.$2,
                    style: TextStyle(
                        color: active ? AppColors.cyan : AppColors.textPrimary,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                onTap: () => onSelect(it.$3),
              );
            }),
            const Spacer(),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.pink),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: AppColors.pink)),
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
