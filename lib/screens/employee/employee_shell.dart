import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/checada_model.dart';
import '../../models/entities.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/futuristic.dart';
import 'check_in_map_screen.dart';

class EmployeeShell extends StatefulWidget {
  final Empleado? empleado;
  final Obra? obra;
  const EmployeeShell({super.key, this.empleado, this.obra});

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _index = 0;
  late final List<Checada> _checadas =
      SupabaseService.instance.isConnected ? [] : MockData.recentChecadas();
  bool _loading = false;

  String get _nombre => widget.empleado?.nombre ?? 'jorge cruz';
  String get _obraNombre => widget.obra?.nombre ?? 'casa';

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    final emp = widget.empleado;
    if (!SupabaseService.instance.isConnected || emp == null) return;
    setState(() => _loading = true);
    final rows = await SupabaseService.instance.checadasByEmpleado(emp.id);
    if (mounted) {
      setState(() {
        _checadas
          ..clear()
          ..addAll(rows);
        _loading = false;
      });
    }
  }

  Future<void> _registrar() async {
    // Require passing the geofence map check before registering.
    final allowed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => CheckInMapScreen(obra: widget.obra)),
    );
    if (allowed != true || !mounted) return;

    final now = DateTime.now();
    final last = _checadas.isNotEmpty ? _checadas.first.type : CheckadaType.salida;
    final next =
        last == CheckadaType.entrada ? CheckadaType.salida : CheckadaType.entrada;

    final emp = widget.empleado;
    if (SupabaseService.instance.isConnected && emp != null) {
      final saved = await SupabaseService.instance.registerChecada(
        empleadoId: emp.id,
        obraId: widget.obra?.id,
        tipo: next,
        lat: widget.obra?.lat,
        lng: widget.obra?.lng,
      );
      if (saved != null && mounted) setState(() => _checadas.insert(0, saved));
    } else {
      final checada = Checada(
        id: now.microsecondsSinceEpoch.toString(),
        employeeId: 'INST001',
        obraId: 'casa',
        type: next,
        status: CheckadaStatus.verified,
        timestamp: now,
        biometricVerified: true,
        createdAt: now,
      );
      setState(() => _checadas.insert(0, checada));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 20),
              const SizedBox(width: 10),
              Text(
                  '${next == CheckadaType.entrada ? 'Entrada' : 'Salida'} registrada correctamente'),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
          checadas: _checadas,
          onRegistrar: _registrar,
          obraNombre: _obraNombre,
          loading: _loading),
      HistoryTab(checadas: _checadas),
      _ProfileTab(empleado: widget.empleado),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Column(
          children: [
            Text(['Hola, $_nombre', 'Historial', 'Perfil'][_index],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.logout_rounded, color: AppColors.pink),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: AuroraBackground(
        child: SafeArea(bottom: false, child: pages[_index]),
      ),
      bottomNavigationBar: _NeonNavBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Checada> checadas;
  final VoidCallback onRegistrar;
  final String obraNombre;
  final bool loading;
  const _HomeTab({
    required this.checadas,
    required this.onRegistrar,
    required this.obraNombre,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        GlassCard(
          glowColor: AppColors.cyan,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Turno activo',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                      Text('Obra: $obraNombre',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              NeonButton(
                label: 'Registrar checada',
                icon: Icons.photo_camera_rounded,
                onPressed: onRegistrar,
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: const [
            Icon(Icons.history_rounded, color: AppColors.purple, size: 20),
            SizedBox(width: 8),
            Text('Últimas checadas',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.cyan)),
          )
        else if (checadas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Sin checadas registradas',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          )
        else
          ...checadas.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChecadaTile(checada: c),
              )),
      ],
    );
  }
}

class ChecadaTile extends StatelessWidget {
  final Checada checada;
  const ChecadaTile({super.key, required this.checada});

  @override
  Widget build(BuildContext context) {
    final isEntrada = checada.type == CheckadaType.entrada;
    final color = isEntrada ? AppColors.green : AppColors.orange;
    final d = checada.timestamp;
    final label =
        '${d.day}/${d.month} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(isEntrada ? Icons.login_rounded : Icons.logout_rounded,
                color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEntrada ? 'Entrada' : 'Salida',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          if (checada.biometricVerified)
            const Icon(Icons.verified_rounded,
                color: AppColors.cyan, size: 20),
        ],
      ),
    );
  }
}

class HistoryTab extends StatefulWidget {
  final List<Checada> checadas;
  const HistoryTab({super.key, required this.checadas});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  Set<int> get _daysWithData => widget.checadas
      .where((c) =>
          c.timestamp.year == _month.year && c.timestamp.month == _month.month)
      .map((c) => c.timestamp.day)
      .toSet();

  List<Checada> get _selectedDayChecadas {
    if (_selected == null) return [];
    return widget.checadas
        .where((c) =>
            c.timestamp.year == _selected!.year &&
            c.timestamp.month == _selected!.month &&
            c.timestamp.day == _selected!.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = first.weekday % 7; // Sun=0
    final data = _daysWithData;
    final dayChecadas = _selectedDayChecadas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() =>
                        _month = DateTime(_month.year, _month.month - 1)),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.cyan),
                  ),
                  Text('${months[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  IconButton(
                    onPressed: () => setState(() =>
                        _month = DateTime(_month.year, _month.month + 1)),
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.cyan),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...List.generate(leadingBlanks, (_) => const SizedBox()),
                  ...List.generate(daysInMonth, (i) {
                    final day = i + 1;
                    final isSel = _selected?.day == day &&
                        _selected?.month == _month.month;
                    final has = data.contains(day);
                    return GestureDetector(
                      onTap: () => setState(() => _selected =
                          DateTime(_month.year, _month.month, day)),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: isSel ? AppGradients.neon : null,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                    color: isSel
                                        ? const Color(0xFF06121F)
                                        : AppColors.textPrimary,
                                    fontWeight: isSel
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    fontSize: 14)),
                            if (has && !isSel)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    color: AppColors.pink,
                                    shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (dayChecadas.isEmpty)
          Column(
            children: const [
              SizedBox(height: 30),
              Icon(Icons.event_busy_rounded,
                  color: AppColors.textMuted, size: 48),
              SizedBox(height: 12),
              Text('Sin registros este día',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          )
        else
          ...dayChecadas.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChecadaTile(checada: c),
              )),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final Empleado? empleado;
  const _ProfileTab({this.empleado});

  @override
  Widget build(BuildContext context) {
    final nombre = empleado?.nombre ?? 'Jorge Cruz';
    final codigo = empleado?.codigo ?? 'INST001';
    final depto = empleado?.departamento ?? 'Encargado';
    final empresa = empleado?.empresa.nombre ?? 'Instalaciones JG';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.neon,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.cyan.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: -4)
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    size: 52, color: Color(0xFF06121F)),
              ),
              const SizedBox(height: 14),
              Text(nombre,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              Text('$codigo · $depto',
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 26),
        GlassCard(
          child: Column(
            children: [
              _ProfileRow(
                  icon: Icons.apartment_rounded,
                  label: 'Empresa',
                  value: empresa),
              const Divider(color: Colors.white24, height: 26),
              const _ProfileRow(
                  icon: Icons.verified_user_rounded,
                  label: 'Biometría',
                  value: 'Activada'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 22),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NeonNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _NeonNavBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.calendar_month_rounded, 'Historial'),
      (Icons.person_rounded, 'Perfil'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        radius: 26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final active = i == index;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                    horizontal: active ? 18 : 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: active ? AppGradients.neon : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(items[i].$1,
                        color: active
                            ? const Color(0xFF06121F)
                            : AppColors.textMuted,
                        size: 22),
                    if (active) ...[
                      const SizedBox(width: 8),
                      Text(items[i].$2,
                          style: const TextStyle(
                              color: Color(0xFF06121F),
                              fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
