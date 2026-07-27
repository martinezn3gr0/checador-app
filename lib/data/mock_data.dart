import 'package:flutter/material.dart';

import '../models/checada_model.dart';
import '../theme/app_theme.dart';

/// In-memory sample data so the redesigned UI is fully navigable without a backend.
class MockData {
  static List<Checada> recentChecadas() {
    final now = DateTime.now();
    Checada c(int hoursAgo, CheckadaType type) {
      final ts = now.subtract(Duration(hours: hoursAgo));
      return Checada(
        id: ts.microsecondsSinceEpoch.toString(),
        employeeId: 'INST001',
        obraId: 'casa',
        type: type,
        status: CheckadaStatus.verified,
        timestamp: ts,
        biometricVerified: true,
        createdAt: ts,
      );
    }

    return [
      c(1, CheckadaType.entrada),
      c(15, CheckadaType.entrada),
      c(40, CheckadaType.salida),
      c(48, CheckadaType.entrada),
      c(60, CheckadaType.entrada),
      c(72, CheckadaType.salida),
    ];
  }

  static const List<DashboardStat> dashboardStats = [
    DashboardStat('Empleados', '12', StatKind.people),
    DashboardStat('Asistencia', '92%', StatKind.trend),
    DashboardStat('Entradas', '9', StatKind.checkIn),
    DashboardStat('Salidas', '5', StatKind.checkOut),
    DashboardStat('Faltas hoy', '1', StatKind.absent),
    DashboardStat('Obras activas', '3', StatKind.works),
  ];

  static const List<AbsenceEntry> absences = [
    AbsenceEntry('jorge cruz', 'INST001 · encargado', 'casa'),
  ];
}

enum StatKind { people, trend, checkIn, checkOut, absent, works }

extension StatKindStyle on StatKind {
  IconData get icon {
    switch (this) {
      case StatKind.people:
        return Icons.groups_rounded;
      case StatKind.trend:
        return Icons.trending_up_rounded;
      case StatKind.checkIn:
        return Icons.login_rounded;
      case StatKind.checkOut:
        return Icons.logout_rounded;
      case StatKind.absent:
        return Icons.person_off_rounded;
      case StatKind.works:
        return Icons.handyman_rounded;
    }
  }

  Color get color {
    switch (this) {
      case StatKind.people:
        return AppColors.cyan;
      case StatKind.trend:
        return AppColors.green;
      case StatKind.checkIn:
        return AppColors.green;
      case StatKind.checkOut:
        return AppColors.orange;
      case StatKind.absent:
        return AppColors.pink;
      case StatKind.works:
        return AppColors.purple;
    }
  }
}

class DashboardStat {
  final String label;
  final String value;
  final StatKind kind;
  const DashboardStat(this.label, this.value, this.kind);
}

class AbsenceEntry {
  final String name;
  final String role;
  final String obra;
  const AbsenceEntry(this.name, this.role, this.obra);
}
